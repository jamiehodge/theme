require_relative "document"

module Theme
  class Directory
    def initialize(path:, repo:)
      @path = path
      @repo = repo
    end

    def document(name)
      Document.new(path: [path, name].join("/"), repo: repo)
    end

    def documents
      tree.map do |entry|
        Document.new(path: [path, entry[:name]].join("/"), repo: repo)
      end
    end

    def exists?
      !!oid
    end

    private

    attr_reader :path, :repo

    def oid
      @oid ||= repo.head.target.tree.path(path)[:oid]
    rescue Rugged::TreeError
    end

    def tree
      @tree ||= repo.lookup(oid)
    end
  end
end
