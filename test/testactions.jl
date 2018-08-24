actions = getallactions!(test_client)

@testset "List all Actions" begin
    @test actions[1].id == 36804636
    @test actions[1].status == "completed"
    @test actions[1].actiontype == "create"
    @test actions[1].started_at == DateTime("2014-11-14T16:29:21")
    @test actions[1].completed_at == DateTime("2014-11-14T16:30:06")
    @test actions[1].resourceid == 3164444
    @test actions[1].resourcetype == "droplet"
    @test actions[1].region.slug == "nyc3"
    @test actions[1].regionslug == "nyc3"
end;

action = getaction!(test_client, 36804636)

@testset "Retrieve an existing Action" begin
    @test action.id == 36804636
    @test action.status == "completed"
    @test action.actiontype == "create"
    @test action.started_at == DateTime("2014-11-14T16:29:21")
    @test action.completed_at == DateTime("2014-11-14T16:30:06")
    @test action.resourceid == 3164444
    @test action.resourcetype == "droplet"
    @test action.region.slug == "nyc3"
    @test action.regionslug == "nyc3"
end;
