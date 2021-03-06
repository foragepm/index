# frozen_string_literal: true

module PackageManager
  class Base
    COLOR = "#fff"
    BIBLIOTHECARY_SUPPORT = false
    BIBLIOTHECARY_PLANNED = false
    SECURITY_PLANNED = false
    HIDDEN = false
    HAS_OWNERS = false
    ENTIRE_PACKAGE_CAN_BE_DEPRECATED = false
    GITHUB_PACKAGE_SUPPORT = false

    def self.platforms
      @platforms ||= begin
        Dir[Rails.root.join("app", "models", "package_manager", "*.rb")].sort.each do |file|
          require file unless file.match(/base\.rb$/)
        end
        PackageManager.constants
          .reject { |platform| platform == :Base }
          .map { |sym| "PackageManager::#{sym}".constantize }
          .reject { |platform| platform::HIDDEN }
          .sort_by(&:name)
      end
    end

    def self.default_language
      Languages::Language.all.find { |l| l.color == color }.try(:name)
    end

    def self.format_name(platform)
      return nil if platform.nil?

      find(platform).to_s.demodulize
    end

    def self.find(platform)
      platforms.find { |p| p.formatted_name.downcase == platform.downcase }
    end

    def self.color
      self::COLOR
    end

    def self.homepage
      self::URL
    end

    def self.formatted_name
      to_s.demodulize
    end

    def self.package_link(_package, _version = nil)
      nil
    end

    def self.download_url(_name, _version = nil)
      nil
    end

    def self.documentation_url(_name, _version = nil)
      nil
    end

    def self.install_instructions(_package, _version = nil)
      nil
    end

    def self.download_registry_users(_name)
      nil
    end

    def self.registry_user_url(_login)
      nil
    end

    def self.check_status_url(package)
      package_link(package)
    end

    def self.platform_name(platform)
      find(platform).try(:formatted_name) || platform
    end

    def self.save(package, version_limit = 20)
      return unless package.present?

      mapped_package = mapping(package)
      mapped_package = mapped_package.delete_if { |_key, value| value.blank? } if mapped_package.present?
      return false unless mapped_package.present?

      dbpackage = Package.find_or_initialize_by({ name: mapped_package[:name], platform: name.demodulize })
      if dbpackage.new_record?
        dbpackage.assign_attributes(mapped_package.except(:name, :releases, :versions, :version, :dependencies, :properties))
        dbpackage.save! if dbpackage.changed?
      else
        dbpackage.reformat_repository_url
        attrs = mapped_package.except(:name, :releases, :versions, :version, :dependencies, :properties)
        dbpackage.update(attrs)
      end

      if self::HAS_VERSIONS
        v = versions(package, dbpackage.name).sort_by{|v| v[:published_at]}.reverse
        v = v.first(version_limit) if version_limit
        v.each do |version|
          dbpackage.versions.create(version) unless dbpackage.versions.find { |v| v.number == version[:number] }
        end
      end

      #save_dependencies(dbpackage, mapped_package) if self::HAS_DEPENDENCIES
      dbpackage.reload
      # dbpackage.download_registry_users
      dbpackage.last_synced_at = Time.now
      dbpackage.save
      dbpackage
    end

    def self.update(name, version_limit = 20)
      pkg = package(name)
      save(pkg, version_limit) if pkg.present?
    rescue SystemExit, Interrupt
      exit 0
    rescue StandardError => e
      if ENV["RACK_ENV"] == "production"
        # Bugsnag.notify(e)
      else
        raise
      end
    end

    def self.import
      return if ENV["READ_ONLY"].present?

      package_names.each { |name| update(name) }
    end

    def self.import_recent
      return if ENV["READ_ONLY"].present?

      recent_names.each { |name| update(name) }
    end

    def self.import_new
      return if ENV["READ_ONLY"].present?

      new_names.each { |name| update(name) }
    end

    def self.new_names
      names = package_names
      existing_names = []
      Package.platform(name.demodulize).select(:id, :name).find_each { |package| existing_names << package.name }
      names - existing_names
    end

    def self.save_dependencies(package, mapped_package)
      name = mapped_package[:name]
      package.versions.includes(:dependencies).each do |version|
        next if version.dependencies.any?

        deps = begin
                 dependencies(name, version.number, mapped_package)
               rescue StandardError
                 []
               end
        next unless deps&.any? && version.dependencies.empty?

        deps.each do |dep|
          named_package_id = Package
            .find_best(self.name.demodulize, dep[:package_name].strip)
            &.id
          version.dependencies.create(dep.merge(package_id: named_package_id.try(:strip)))
        end
        version.set_runtime_dependencies_count
      end
    end

    def self.dependencies(_name, _version, _package)
      []
    end

    def self.map_dependencies(deps, kind, optional = false, platform = name.demodulize)
      deps.map do |k, v|
        {
          package_name: k,
          requirements: v,
          kind: kind,
          optional: optional,
          platform: platform,
        }
      end
    end

    def self.find_and_map_dependencies(name, version, _package)
      dependencies = find_dependencies(name, version)
      return [] unless dependencies&.any?

      dependencies.map do |dependency|
        dependency = dependency.deep_stringify_keys
        {
          package_name: dependency["name"],
          requirements: dependency["requirement"] || "*",
          kind: dependency["type"],
          platform: self.name.demodulize,
        }
      end
    end

    def self.repo_fallback(repo, homepage)
      repo = "" if repo.nil?
      homepage = "" if homepage.nil?
      repo_url = UrlParser.try_all(repo)
      homepage_url = UrlParser.try_all(homepage)
      if repo_url.present?
        repo_url
      elsif homepage_url.present?
        homepage_url
      else
        repo
      end
    end

    def self.package_find_names(package_name)
      [package_name]
    end

    def self.deprecation_info(_name)
      { is_deprecated: false, message: nil }
    end

    def self.dependents(name)
      []
    end

    private_class_method def self.get(url, options = {})
      Oj.load(get_raw(url, options))
    end

    private_class_method def self.get_raw(url, options = {})
      request(url, options).body
    end

    private_class_method def self.request(url, options = {})
      connection = Faraday.new url.strip, options do |builder|
        builder.use FaradayMiddleware::Gzip
        builder.use FaradayMiddleware::FollowRedirects, limit: 3
        builder.request :retry, { max: 2, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2 }

        builder.use :instrumentation
        builder.adapter :typhoeus
      end
      connection.get
    end

    private_class_method def self.get_html(url, options = {})
      Nokogiri::HTML(get_raw(url, options))
    end

    private_class_method def self.get_xml(url, options = {})
      Ox.parse(get_raw(url, options))
    end

    private_class_method def self.get_json(url)
      get(url, headers: { "Accept" => "application/json" })
    end
  end
end
