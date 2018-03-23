volumes = get_all_volumes(test_client)

@testset "List all Volumes" begin
    @test length(volumes) == 2
    @test volumes[2].id == "2d2967ff-491d-11e6-860c-000f53315870"
    @test volumes[2].region.name == "New York 1"
    @test "metadata" in volumes[2].region.features
    @test 19486237 in volumes[2].droplet_ids
    @test volumes[2].name == "another-example"
    @test volumes[2].description == "A bigger example volume"
    @test volumes[2].size_gigabytes == 500
    @test volumes[2].created_at == Dates.DateTime("2016-03-05T17:00:49")
end;

volume = create_volume(test_client; size_gigabytes=10, name="example",
                       description="Block store for examples", region="nyc1")

@testset "Create a new Volume" begin
    @test true
end;
