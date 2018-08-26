account = getaccount!(client)

@testset "Get User Information" begin
    @test account.email == "sammy@digitalocean.com"
    @test account.dropletlimit == 25
    @test account.floatingiplimit == 5
    @test account.uuid == "b6fr89dbf6d9156cace5f3c78dc9851d957381ef"
    @test account.emailverified
    @test account.status == "active"
    @test account.statusmessage == ""
end;
