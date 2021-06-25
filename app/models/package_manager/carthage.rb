module PackageManager
  class Carthage < Base
    HAS_VERSIONS = false
    HAS_DEPENDENCIES = false
    BIBLIOTHECARY_SUPPORT = true
    URL = 'https://github.com/Carthage/Carthage'
    COLOR = '#ffac45'

    def self.package_names
      Manifest.platform('Carthage').includes(:repository_dependencies).map{|m| m.repository_dependencies.map(&:package_name).compact.map(&:downcase)}.flatten.uniq
    end

    def self.package(name)
      if name.match(/^([-\w]+)\/([-.\w]+)$/)
        begin
          repo = AuthToken.client.repo(name, accept: 'application/vnd.github.drax-preview+json,application/vnd.github.mercy-preview+json')
          return repo.to_hash
        rescue
          return nil
        end
      elsif name_with_owner = GitlabUrlParser.parse(name)
        begin
          repo = AuthToken.client.repo(name_with_owner, accept: 'application/vnd.github.drax-preview+json,application/vnd.github.mercy-preview+json')
          return repo.to_hash
        rescue
          return nil
        end
      elsif name.match(/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/)
        begin
          response = request(name)
          if response.status == 200
            {
              full_name: name.sub(/^https?\:\/\//, ''),
              homepage: name
            }
          end
        rescue
          nil
        end
      end
    end

    def self.mapping(package)
      {
        :name => package[:full_name],
        :description => package[:description],
        :homepage => package[:homepage],
        :keywords_array => package[:topics],
        :licenses => (package.fetch(:license, {}) || {})[:key],
        :repository_url => package[:html_url]
      }
    end
  end
end
