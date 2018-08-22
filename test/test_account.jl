account = get_account(test_client)

@testset "Account Equality" begin
    account2 = get_account(test_client)
    @test account == account2
end

@testset "Get User Information" begin
    @test account.email == "sammy@digitalocean.com"
    @test account.droplet_limit == 25
    @test account.floating_ip_limit == 5
    @test account.uuid == "b6fr89dbf6d9156cace5f3c78dc9851d957381ef"
    @test account.email_verified
    @test account.status == "active"
    @test account.status_message == ""
end;
