domains = get_all_domains(test_client)

@testset "List all Domains" begin
    @test length(domains) == 1
    @test domains[1].name == "example.com"
    @test domains[1].ttl == 1800
    @test occursin("IN SOA ns1.digitalocean.com.", domains[1].zone_file)
end;

domain = get_domain(test_client, "example.com")

@testset "Retrieve an existing Domain" begin
    @test domain.name == "example.com"
    @test domain.ttl == 1800
    @test occursin("IN SOA ns1.digitalocean.com.", domain.zone_file)
end;

domain = create_domain(test_client; name="example.com", ip_address="1.2.3.4")

@testset "Create a new Domain" begin
    @test domain.name == "example.com"
    @test domain.ttl == 1800
    @test domain.zone_file == nothing
end;

@testset "Delete a Domain" begin
    @test delete_domain(test_client, domain)
end;
