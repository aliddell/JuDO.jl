using JuDO
using Base.Test

token = ENV["dotok"]
manager = JuDO.Manager(token)

# load account
account = get_account(manager)
@testset "Account" begin
    @test contains(account.email, "liddell")
    @test account.droplet_limit == 50
    @test account.floating_ip_limit == 3
    @test account.email_verified
    @test account.status == "active"
end;

@testset "Manager" begin
    @test manager.ratelimit_limit <= 5000
    @test manager.ratelimit_remaining < manager.ratelimit_limit
end;

# SSH keys
