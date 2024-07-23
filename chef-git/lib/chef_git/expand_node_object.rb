require 'chef/policy_builder/expand_node_object'
require 'pathname'

class ChefGit::ExpandNodeObject < Chef::PolicyBuilder::ExpandNodeObject

  class CommandFailed < StandardError
    attr_reader :command, :status

    def initialize(command, status)
      @command = command
      @status  = status
    end

    def message
      title = @command.join(' ').inspect
      return "#{title} exited with status #{status.exitstatus}" if status.exited?
      return "#{title} died with signal #{status.termsig}" if status.signalled?
      "#{title} died of unknown causes: #{status.inspect}"
    end
  end

  def cleanup_git
    Dir.chdir(ChefGit::REPO_PATH) do
      git('remote', 'prune', 'origin')
      git('gc', '--auto', '--aggressive')
    end
  end

  def check_out_git
    return if @git_repo
    repo = Pathname.new(ChefGit::REPO_PATH)
    Dir.chdir(repo) do
      git('fetch', 'origin')
      git('reset', '--hard')
      git('clean', '-fd')
      git('checkout', "origin/#{@node.chef_environment}")

      unless Dir.exist?('cookbooks-upstream')
        require 'librarian/chef/cli'
        Librarian::Chef::Cli.with_environment { Librarian::Chef::Cli.start(['install']) }
      end
    end
    @git_repo = repo

    Chef::Config[:cookbook_path] = [(@git_repo + 'cookbooks').to_s]
    upstream_cookbook_path = (@git_repo + 'cookbooks-upstream').to_s
    if Dir.exist?(upstream_cookbook_path)
      Chef::Config[:cookbook_path] << upstream_cookbook_path
    else
      Chef::Config[:cookbook_path] << (@git_repo + 'tmp/librarian/cookbooks').to_s
    end
    Chef::Config[:role_path] = (@git_repo + 'roles').to_s
  end

  def setup_run_context(specific_recipes=nil)
    cleanup_git if Time.now.hour == 3
    check_out_git

    # We need to act like :solo = true but not actually set it.
    Chef::Cookbook::FileVendor.fetch_from_disk(Chef::Config[:cookbook_path])
    cl = Chef::CookbookLoader.new(Chef::Config[:cookbook_path])
    cl.load_cookbooks
    cookbook_collection = Chef::CookbookCollection.new(cl)
    cookbook_collection.validate!
    run_context = Chef::RunContext.new(node, cookbook_collection, @events)

    # TODO: this is really obviously not the place for this
    # FIXME: need same edits
    setup_chef_class(run_context)

    # TODO: this is not the place for this. It should be in Runner or
    # CookbookCompiler or something.
    run_context.load(@run_list_expansion)
    if specific_recipes
      specific_recipes.each do |recipe_file|
        run_context.load_recipe_file(recipe_file)
      end
    end
    run_context
  end

  def expand_run_list
    check_out_git

    @run_list_expansion = node.expand!('disk')

    # @run_list_expansion is a RunListExpansion.
    #
    # Convert @expanded_run_list, which is an
    # Array of Hashes of the form
    #   {:name => NAME, :version_constraint => Chef::VersionConstraint },
    # into @expanded_run_list_with_versions, an
    # Array of Strings of the form
    #   "#{NAME}@#{VERSION}"
    @expanded_run_list_with_versions = @run_list_expansion.recipes.with_version_constraints_strings
    @run_list_expansion
  rescue Exception => e
    # TODO: wrap/munge exception with useful error output.
    events.run_list_expand_failed(node, e)
    raise
  end

  private

  def git(*args)
    command('git', *args)
  end

  def command(*command)
    system(*command)
    raise CommandFailed.new(command, $?) unless $?.success?
  end

  def resolve_file_paths(cookbook, cookbook_path)
    Chef::CookbookVersion::COOKBOOK_SEGMENTS.each do |segment|
      paths = cookbook.manifest[segment].map { |mani| (cookbook_path + mani['path']).to_s }

      if segment.to_sym == :recipes
        cookbook.recipe_filenames = paths
      elsif segment.to_sym == :attributes
        cookbook.attribute_filenames = paths
      else
        cookbook.segment_filenames(segment).replace(paths)
      end
    end
  end
end
