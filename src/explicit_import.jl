
# planet_parameters = names(CLIMA.Parameters.Planet, all=true)
planet_parameters = ["molmass_dryair","R_d","kappa_d","cp_d","cv_d","ρ_cloud_liq","ρ_cloud_ice","molmass_water","molmass_ratio","R_v","cp_v","cp_l","cp_i","cv_v","cv_l","cv_i","T_freeze","T_min","T_max","T_icenuc","T_triple","T_0","LH_v0","LH_s0","LH_f0","e_int_v0","e_int_i0","press_triple","ρ_ocean","cp_ocean","planet_radius","day","Omega","grav","year_anom","orbit_semimaj","TSI","MSLP"]

function explicit_import(filename, _usingmodule)

  parameters_found = []
  contents = open(f->read(f, String), filename)
  for pp in planet_parameters
    if occursin(pp, contents)
      push!(parameters_found, pp)
    end
  end

  i = findfirst("$(_usingmodule)\n", contents)
  if i ≠ nothing && !isempty(parameters_found)
    contents = replace(contents, "$(_usingmodule)\n" => "$(_usingmodule): "*join(parameters_found, ", ")*"\n")
  end
  if isempty(parameters_found)
    contents = replace(contents, "$(_usingmodule)\n" => "")
  end
  open(filename,"w") do io
    print(io, contents)
  end
end

code_dir = joinpath(@__DIR__, "..")
all_files = [joinpath(root, f) for (root, dirs, files) in Base.Filesystem.walkdir(code_dir) for f in files]
_usingmodule = "using CLIMA.PlanetParameters"

filter!(x->endswith(x, ".jl"), all_files)
filter!(x->!endswith(x, "runtests.jl"), all_files)
filter!(x->!occursin("$(basename(@__FILE__))", x), all_files)
filter!(x->occursin("$(_usingmodule)", open(f->read(f, String), x)), all_files)
filter!(x->!occursin("$(_usingmodule):", open(f->read(f, String), x)), all_files)

@show code_dir
for f in all_files
  file = joinpath(last(split(f, "..")))
  @show file
end

for driver in all_files
  explicit_import(driver, _usingmodule)
end

