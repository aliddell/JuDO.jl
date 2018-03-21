using JuDO
using Base.Test

token = ENV["dotok"]
manager = JuDO.Manager(token)

@testset "Manager" begin
    @test manager.ratelimit_limit <= 5000
    @test manager.ratelimit_remaining < manager.ratelimit_limit
    @test manager.ratelimit_reset < now() + Dates.Hour(1)
end;
