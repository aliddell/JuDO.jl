struct Image
    id::Integer
    name::String
    itype::String
    distribution::String
    slug::String
    public::Bool
    regions::Array{String, 1}
    min_disk_size::Integer
    size_gigabytes::Real
    created_at::String
end

function show(io::IO, i::Image)
    print(io, "Image ($(i.name))")
end
