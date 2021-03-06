domains = getalldomains!(client)

@testset "List all Domains" begin
    @test length(domains) == 1
    @test domains[1].name == "example.com"
    @test domains[1].ttl == 1800
    @test occursin("IN SOA ns1.digitalocean.com.", domains[1].zonefile)
end;

domain = getdomain!(client, "example.com")

@testset "Retrieve an existing Domain" begin
    @test domain.name == "example.com"
    @test domain.ttl == 1800
    @test occursin("IN SOA ns1.digitalocean.com.", domain.zonefile)
end;

domain = createdomain!(client; name="example.com", ip_address="1.2.3.4")

@testset "Create a new Domain" begin
    @test domain.name == "example.com"
    @test domain.ttl == 1800
    @test domain.zonefile == nothing
end;

@testset "Delete a Domain" begin
    @test deletedomain!(client, domain)
end;
