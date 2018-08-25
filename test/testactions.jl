actions = getallactions!(testclient)

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
    @test "s-16vcpu-64gb" in actions[1].region.sizes
    @test "private_networking" in actions[1].region.features
end;

action = getaction!(testclient, 36804636)

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
    @test "s-4vcpu-8gb" in action.region.sizes
    @test "metadata" in action.region.features
end;
