domain = "example.com"

records = getalldomainrecords!(testclient, domain)
@testset "List all Domain Records" begin
    @test length(records) == 4
    @test records[1].id == 28448429
    @test records[1].recordtype == "NS"
    @test records[1].name == "@"
    @test records[1].data == "ns1.digitalocean.com"
    @test records[1].priority == nothing
    @test records[1].port == nothing
    @test records[1].ttl == 1800
    @test records[1].weight == nothing
    @test records[1].flags == nothing
    @test records[1].tag == nothing
end;

record = createdomainrecord!(testclient, domain, "A"; name="www", data="162.10.66.0",
                             ttl=1800)
@testset "Create a new Domain Record" begin
    @test record.id == 28448433
    @test record.recordtype == "A"
    @test record.name == "www"
    @test record.data == "162.10.66.0"
    @test record.priority == nothing
    @test record.port == nothing
    @test record.ttl == 1800
    @test record.weight == nothing
    @test record.flags == nothing
    @test record.tag == nothing
end;

record = getdomainrecord!(testclient, "example.com", 28448433)
@testset "Retrieve an existing Domain Record" begin
    @test record.id == 28448433
    @test record.recordtype == "A"
    @test record.name == "www"
    @test record.data == "162.10.66.0"
    @test record.priority == nothing
    @test record.port == nothing
    @test record.ttl == 1800
    @test record.weight == nothing
    @test record.flags == nothing
    @test record.tag == nothing
end;

record = updatedomainrecord!(testclient, "example.com", record, name="blog")
@testset "Update a Domain Record" begin
    @test record.id == 28448433
    @test record.recordtype == "A"
    @test record.name == "blog"
    @test record.data == "162.10.66.0"
    @test record.priority == nothing
    @test record.port == nothing
    @test record.ttl == 1800
    @test record.weight == nothing
    @test record.flags == nothing
    @test record.tag == nothing
end;

@testset "Delete a Domain Record" begin
    @test deletedomainrecord!(testclient, "example.com", record)
end;
