export get_initial_compat

"""
    get_initial_compat(filename_manifest::S, filename_project::S) where {S<:AbstractString}

A string containing a "first guess" for the `[compat]`
section in a Julia `Project.toml` file, based on existing
packages in the Manifest.toml.
"""
function get_initial_compat(
  filename_manifest::S,
  filename_project::S,
  excludes =
  ["Test",
  "Pkg",
  "InteractiveUtils",
  "Profile"]
  ) where {S<:AbstractString}
  manifest = open(f->read(f, String), filename_manifest)
  project = open(f->read(f, String), filename_project)

  deps = last(split(project, "[deps]"))
  deps = first(split(deps, "[compat]"))
  deps = split(deps, "\n")
  filter!(x->!isempty(x), deps)
  deps = [first(split(x, " = ")) for x in deps]
  filter!(x->!any([x==y for y in excludes]), deps)

  man = split(manifest, "\n\n")
  filter!(x->occursin("[", x), man)
  man = [split(x, "\n") for x in man]
  s = "version ="
  man = Dict([replace(replace(first(x), "[" =>""), "]"=>"") => last(split(last(x),s)) for x in man if occursin(s, last(x))])
  for (k,v) in man
    man[k] = strip(replace(v, "\"" => ""))
  end

  compat = ["$x = \"$(man[x])\"" for x in deps]
  pushfirst!(compat, "[compat]")
  return join(compat, "\n")
end
