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
    @test volumes[2].created_at == DateTime("2016-03-05T17:00:49")
end;

volume = create_volume(test_client; size_gigabytes=10, name="example",
                       description="Block store for examples",
                       region="nyc1")

@testset "Create a new Volume" begin
    @test volume.id == "506f78a4-e098-11e5-ad9f-000f53306ae1"
    @test volume.region.name == "New York 1"
    @test "private_networking" in volume.region.features
    @test isempty(volume.droplet_ids)
    @test volume.name == "example"
    @test volume.description == "Block store for examples"
    @test volume.size_gigabytes == 10
    @test volume.created_at == DateTime("2016-03-02T17:00:49")
end;

volume = get_volume(test_client, volume)

@testset "Retrieve an existing Volume" begin
    @test volume.id == "506f78a4-e098-11e5-ad9f-000f53306ae1"
    @test volume.region.name == "New York 1"
    @test "private_networking" in volume.region.features
    @test isempty(volume.droplet_ids)
    @test volume.name == "example"
    @test volume.description == "Block store for examples"
    @test volume.size_gigabytes == 10
    @test volume.created_at == DateTime("2016-03-02T17:00:49")
end;

volume_id = "82a48a18-873f-11e6-96bf-000f53315a41"
snapshots = get_all_volume_snapshots(test_client, volume_id)

@testset "List Snapshots for a Volume" begin
    @test length(snapshots) == 1
    @test snapshots[1].id == "8eb4d51a-873f-11e6-96bf-000f53315a41"
    @test snapshots[1].name == "big-data-snapshot1475261752"
    @test snapshots[1].regions[1] == "nyc1"
    @test snapshots[1].created_at == DateTime("2016-09-30T18:56:12")
    @test snapshots[1].resource_id == "82a48a18-873f-11e6-96bf-000f53315a41"
    @test snapshots[1].resource_type == "volume"
    @test snapshots[1].min_disk_size == 10
    @test snapshots[1].size_gigabytes == 0
end;

snapshot = create_snapshot_from_volume(test_client, volume_id;
                                       name="big-data-snapshot1475261774")

@testset "Create a Snapshot from a Volume" begin
    @test snapshot.id == "8fa70202-873f-11e6-8b68-000f533176b1"
    @test snapshot.name == "big-data-snapshot1475261774"
    @test snapshot.regions[1] == "nyc1"
    @test snapshot.created_at == DateTime("2016-09-30T18:56:14")
    @test snapshot.resource_id == "82a48a18-873f-11e6-96bf-000f53315a41"
    @test snapshot.resource_type == "volume"
    @test snapshot.min_disk_size == 10
    @test snapshot.size_gigabytes == 0
end;

@testset "Delete a Volume" begin
    @test delete_volume(test_client, volume)
end;

action = attach_volume(test_client, "7724db7c-e098-11e5-b522-000f53304e51";
                       droplet_id=11612190)

@testset "Attach a Volume to a Droplet" begin
    @test action.id == 72531856
    @test action.status == "completed"
    @test action.action_type == "attach_volume"
    @test action.started_at == DateTime("2015-11-12T17:51:03")
    @test action.completed_at.value == DateTime("2015-11-12T17:51:14")
    @test !action.resource_id.hasvalue
    @test action.resource_type == "volume"
end;

action = remove_volume(test_client, "7724db7c-e098-11e5-b522-000f53304e51";
                       droplet_id=11612190, region="nyc1")

@testset "Remove a Volume from a Droplet" begin
    @test action.id == 68212773
    @test action.status == "in-progress"
    @test action.action_type == "detach_volume"
    @test action.started_at == DateTime("2015-10-15T17:46:15")
    @test !action.completed_at.hasvalue
    @test !action.resource_id.hasvalue
    @test action.resource_type == "backend"
end;

action = resize_volume(test_client, "7724db7c-e098-11e5-b522-000f53304e51";
                       size_gigabytes=10, region="nyc1")

@testset "Resize a Volume" begin
    @test action.id == 72531856
    @test action.status == "in-progress"
    @test action.action_type == "resize"
    @test action.started_at == DateTime("2015-11-12T17:51:03")
    @test action.completed_at.value == DateTime("2015-11-12T17:51:14")
    @test !action.resource_id.hasvalue
    @test action.resource_type == "volume"
end;

actions = get_all_volume_actions(test_client, "7724db7c-e098-11e5-b522-000f53304e51")

@testset "List all Actions for a Volume" begin
    @test length(actions) == 1
    @test actions[1].id == 72531856
    @test actions[1].status == "completed"
    @test actions[1].action_type == "attach_volume"
    @test actions[1].started_at == DateTime("2015-11-21T21:51:09")
    @test actions[1].completed_at.value == DateTime("2015-11-21T21:51:09")
    @test !actions[1].resource_id.hasvalue
    @test actions[1].resource_type == "volume"
end;

action = get_volume_action(test_client, "7724db7c-e098-11e5-b522-000f53304e51",
                           72531856)

@testset "Retrieve an existing Volume Action" begin
    @test action.id == 72531856
    @test action.status == "completed"
    @test action.action_type == "attach_volume"
    @test action.started_at == DateTime("2015-11-12T17:51:03")
    @test action.completed_at.value == DateTime("2015-11-12T17:51:14")
    @test !action.resource_id.hasvalue
    @test action.resource_type == "volume"
end;
