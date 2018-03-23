actions = get_all_actions(test_client)

@testset "List all Actions" begin
    @test length(actions) == 159
    @test actions[1].id == 36804636
    @test actions[1].status == "completed"
    @test actions[1].action_type == "create"
    @test actions[1].started_at == Dates.DateTime("2014-11-14T16:29:21")
    @test actions[1].completed_at.value == Dates.DateTime("2014-11-14T16:30:06")
    @test actions[1].resource_id.value == 3164444
    @test actions[1].resource_type == "droplet"
    @test actions[1].region.value.slug == "nyc3"
    @test actions[1].region_slug.value == "nyc3"
end;

action = get_action(test_client, 36804636)

@testset "Retrieve an existing Action" begin
    @test action.id == 36804636
    @test action.status == "completed"
    @test action.action_type == "create"
    @test action.started_at == Dates.DateTime("2014-11-14T16:29:21")
    @test action.completed_at.value == Dates.DateTime("2014-11-14T16:30:06")
    @test action.resource_id.value == 3164444
    @test action.resource_type == "droplet"
    @test action.region.value.slug == "nyc3"
    @test action.region_slug.value == "nyc3"
end;
