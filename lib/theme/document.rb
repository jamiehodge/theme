require "forwardable"

module Theme
  class Document
    extend Forwardable

    def initialize(path:, repo:, **options)
      @path = path
      @repo = repo
      @commit = options.fetch(:commit) { repo.last_commit }
    end

    def exists?
      !!oid
    end

    def name
      File.basename(path)
    end

    def parent
      walker = Rugged::Walker.new(repo)
      walker.push(repo.last_commit)

      commit = walker.find {|commit| commit.tree.path(path)[:oid] != oid }

      self.class.new(path: path, repo: repo, commit: commit) if commit
    rescue Rugged::TreeError
    end

    def to_h
      { content: content, name: name, size: size }
    end

    def update(content:, message: "", user:)
      oid = repo.write(content, :blob)

      index = repo.index
      index.read_tree(repo.last_commit.tree)
      index.add(path: path, oid: oid, mode: 0100644)

      tree_oid = index.write_tree(repo)

      Rugged::Commit.create(repo,
        author: signature(user),
        committer: signature(user),
        message: message,
        parents: [repo.last_commit],
        tree: tree_oid,
        update_ref: "HEAD"
      )

      self.class.new(path: path, repo: repo)
    end

    def_delegators :blob, :binary?, :content, :size, :text, :sloc

    private

    attr_reader :commit, :path, :repo

    def blob
      @blob ||= repo.lookup(oid)
    end

    def oid
      @oid ||= commit.tree.path(path)[:oid]
    rescue Rugged::TreeError
    end

    def signature(user)
      { email: user.email, name: user.name, time: Time.now }
    end
  end
end
