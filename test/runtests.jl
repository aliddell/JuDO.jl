using JuDO
using Base.Test

token = ENV["dotok"]
manager = JuDO.Manager(token)

@test true
