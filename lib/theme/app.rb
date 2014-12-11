require "roda"
require "rugged"

require_relative "document"
require_relative "directory"

User = Struct.new(:name, :email)

module Theme
  class App < Roda
    plugin :json

    route do |r|
      @user = User.new("jamie", "jhodge@zendesk.com")

      r.on(:repository) do |repository|
        begin
          @repo = Rugged::Repository.new(["repositories", repository].join("/"))
        rescue Rugged::OSError
          r.halt
        end

        r.on(:directory) do |directory|
          @directory = Directory.new(path: directory, repo: @repo)

          r.halt unless @directory.exists?

          r.is do
            r.get do
              @directory.documents.map do |document|
                document.to_h.merge(url: [r.url, document.name].join("/"))
              end
            end
          end

          r.on(:document) do |document|
            @document = @directory.document(document)

            r.halt unless @document.exists?

            r.is do
              r.get do
                @document.to_h.merge(url: r.url)
              end

              r.post do
                @document
                .update(user: @user, content: r.params["content"])
                .to_h.merge(url: r.url)
              end
            end

            r.get("parent") do
              @document.parent.to_h.merge(url: r.url)
            end
          end
        end
      end
    end
  end
end
