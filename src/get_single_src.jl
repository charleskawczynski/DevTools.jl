# module CodeAnalysis

# # TODO: Make OS-independent
# const newline = "\n"
# struct JuliaModule
#   modulename::AbstractString
#   code::AbstractString
#   submodules::Array{JuliaModule}
# end
const DEBUG = false

# TODO: add filter for comments
has_a_module(filename) = occursin("\nmodule ", open(f->read(f, String), filename))
has_an_include(filename) = occursin("\ninclude(", open(f->read(f, String), filename))

"""
    get_single_src(filename)

Returns `contents`, a string containing the
entire source code from `filename`
recursively through `include` statements.
"""
function get_single_src(filename)
  contents = open(f->read(f, String), filename)
  if has_an_include(filename)
    # TODO: Avoid commented `include`'s (requires greedy check of #-\n and scope-check on #= =#)
    incl = "include("
    contents_split = split(contents, "\n"*incl)
    subcontents = Dict()
    for c in contents_split[2:end]
      DEBUG && println("-------")
      i = findfirst(')', c)
      DEBUG && @show filename
      DEBUG && @show i
      # @show c
      jp = "joinpath("
      k_raw = c[1:i-1]
      k_raw = replace(k_raw, jp => "")
      DEBUG && @show k_raw

      k = k_raw
      DEBUG && @show k

      k_processed = k
      if occursin(",", k)
        k_processed = replace(k_processed, "\""=> "")
        k_processed = split(k_processed, ",")
        filter!(x->!(x=="\n"), k_processed)
        filter!(x->!(x==""), k_processed)
        k_processed = strip.(k_processed)
        k_processed = convert.(String, k_processed)
        k_processed = joinpath(k_processed...)
        s_to_replace = "$(jp)$(k_raw))" # or s_to_replace = "$(jp)$(k_raw)\n)"
      else
        k_processed = replace(k_processed, "\""=> "")
        s_to_replace = "$(incl)$(k_raw))" # or s_to_replace = "$(jp)$(k_raw)\n)"
      end
      i = findfirst(s_to_replace, contents)
      DEBUG && @show s_to_replace
      DEBUG && @show i
      DEBUG && println("-------")
      subcontents[k_processed] = get_single_src(joinpath(dirname(filename), k_processed))
      contents = replace(contents, s_to_replace=>subcontents[k_processed])
    end
  end
  return contents
end


# contents = get_single_src(joinpath(@__DIR__, "..", "src", "Common", "MoistThermodynamics", "MoistThermodynamics.jl")); # works
# contents = get_single_src(joinpath(@__DIR__, "..", "src", "Atmos", "Model", "AtmosModel.jl")); # works
contents = get_single_src(joinpath(@__DIR__, "..", "src", "CLIMA.jl"));
# for line in split(contents, "\n")
#   @show line
# end
nothing

# function assemble_modules(src_dir, package_name)
#   all_files = [joinpath(root, f) for (root, dirs, files) in Base.Filesystem.walkdir(src_dir) for f in files]
#   filter!(x->endswith(x, ".jl"), all_files)
#   filter!(x->!endswith(x, ".jll"), all_files)
#   root_src = joinpath(src_dir, package_name*".jl")

#   contents = open(f->read(f, String), root_src)
#   contents = open(f->read(f, String), root_src)
#   if has_an_include(root_src)
#   end
#   for line in split(contents, newline)
#     if occursin(line)

#     end
#   end

#   return JuliaModule(package_name, code, submodules)
# end


# function explicit_import(filename, _usingmodule)

#   parameters_found = []
#   contents = open(f->read(f, String), filename)
#   for pp in planet_parameters
#     if occursin(pp, contents)
#       push!(parameters_found, pp)
#     end
#   end

#   i = findfirst("$(_usingmodule)\n", contents)
#   if i ≠ nothing && !isempty(parameters_found)
#     contents = replace(contents, "$(_usingmodule)\n" => "$(_usingmodule): "*join(parameters_found, ", ")*"\n")
#   end
#   if isempty(parameters_found)
#     contents = replace(contents, "$(_usingmodule)\n" => "")
#   end
#   open(filename,"w") do io
#     print(io, contents)
#   end
# end

# src_dir = joinpath(@__DIR__, "..")
# all_files = [joinpath(root, f) for (root, dirs, files) in Base.Filesystem.walkdir(src_dir) for f in files]
# _usingmodule = "using CLIMA.PlanetParameters"

# filter!(x->endswith(x, ".jl"), all_files)
# filter!(x->!endswith(x, "runtests.jl"), all_files)
# filter!(x->occursin("$(_usingmodule)", open(f->read(f, String), x)), all_files)
# filter!(x->!occursin("$(_usingmodule):", open(f->read(f, String), x)), all_files)

# for driver in all_files
#   explicit_import(driver, _usingmodule)
# end

# end