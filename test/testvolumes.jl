volumes = getallvolumes!(testclient)

@testset "List all Volumes" begin
    @test length(volumes) == 1
    @test volumes[1].id == "506f78a4-e098-11e5-ad9f-000f53306ae1"
    @test volumes[1].region.name == "New York 1"
    @test "metadata" in volumes[1].region.features
    @test "s-3vcpu-1gb" in volumes[1].region.sizes
    @test isempty(volumes[1].droplet_ids)
    @test volumes[1].name == "example"
    @test volumes[1].description == "Block store for examples"
    @test volumes[1].sizegigabytes == 10
    @test volumes[1].created_at == DateTime("2016-03-02T17:00:49")

end;

volume = createvolume!(testclient; size_gigabytes=10, name="example",
                       description="Block store for examples",
                       region="nyc1")

@testset "Create a new Volume" begin
    @test volume.id == "506f78a4-e098-11e5-ad9f-000f53306ae1"
    @test volume.region.name == "New York 1"
    @test "private_networking" in volume.region.features
    @test isempty(volume.droplet_ids)
    @test volume.name == "example"
    @test volume.description == "Block store for examples"
    @test volume.sizegigabytes == 10
    @test volume.created_at == DateTime("2016-03-02T17:00:49")
end;

volume = getvolume!(testclient, volume)

@testset "Retrieve an existing Volume" begin
    @test volume.id == "506f78a4-e098-11e5-ad9f-000f53306ae1"
    @test volume.region.name == "New York 1"
    @test "private_networking" in volume.region.features
    @test isempty(volume.droplet_ids)
    @test volume.name == "example"
    @test volume.description == "Block store for examples"
    @test volume.sizegigabytes == 10
    @test volume.created_at == DateTime("2016-03-02T17:00:49")
end;

volume_id = "82a48a18-873f-11e6-96bf-000f53315a41"
snapshots = getallvolumesnapshots!(testclient, volume_id)

@testset "List Snapshots for a Volume" begin
    @test length(snapshots) == 1
    @test snapshots[1].id == "8eb4d51a-873f-11e6-96bf-000f53315a41"
    @test snapshots[1].name == "big-data-snapshot1475261752"
    @test snapshots[1].regions[1] == "nyc1"
    @test snapshots[1].created_at == DateTime("2016-09-30T18:56:12")
    @test snapshots[1].resourceid == "82a48a18-873f-11e6-96bf-000f53315a41"
    @test snapshots[1].resourcetype == "volume"
    @test snapshots[1].min_disk_size == 10
    @test snapshots[1].sizegigabytes == 0
end;

snapshot = snapshotvolume!(testclient, volume_id;
                                       name="big-data-snapshot1475261774")

@testset "Create a Snapshot from a Volume" begin
    @test snapshot.id == "8fa70202-873f-11e6-8b68-000f533176b1"
    @test snapshot.name == "big-data-snapshot1475261774"
    @test snapshot.regions[1] == "nyc1"
    @test snapshot.created_at == DateTime("2016-09-30T18:56:14")
    @test snapshot.resourceid == "82a48a18-873f-11e6-96bf-000f53315a41"
    @test snapshot.resourcetype == "volume"
    @test snapshot.min_disk_size == 10
    @test snapshot.sizegigabytes == 0
end;

@testset "Delete a Volume" begin
    @test deletevolume!(testclient, volume)
end;

action = attachvolume!(testclient, "7724db7c-e098-11e5-b522-000f53304e51";
                       droplet_id=11612190)

@testset "Attach a Volume to a Droplet" begin
    @test action.id == 72531856
    @test action.status == "completed"
    @test action.actiontype == "attach_volume"
    @test action.started_at == DateTime("2015-11-12T17:51:03")
    @test action.completed_at == DateTime("2015-11-12T17:51:14")
    @test action.resourceid == nothing
    @test action.resourcetype == "volume"
end;

action = removevolume!(testclient, "7724db7c-e098-11e5-b522-000f53304e51";
                       droplet_id=11612190, region="nyc1")

@testset "Remove a Volume from a Droplet" begin
    @test action.id == 68212773
    @test action.status == "in-progress"
    @test action.actiontype == "detach_volume"
    @test action.started_at == DateTime("2015-10-15T17:46:15")
    @test action.completed_at == nothing
    @test action.resourceid == nothing
    @test action.resourcetype == "backend"
end;

action = resizevolume!(testclient, "7724db7c-e098-11e5-b522-000f53304e51";
                       size_gigabytes=10, region="nyc1")

@testset "Resize a Volume" begin
    @test action.id == 72531856
    @test action.status == "in-progress"
    @test action.actiontype == "resize"
    @test action.started_at == DateTime("2015-11-12T17:51:03")
    @test action.completed_at == DateTime("2015-11-12T17:51:14")
    @test action.resourceid == nothing
    @test action.resourcetype == "volume"
end;

actions = getallvolumeactions!(testclient, "7724db7c-e098-11e5-b522-000f53304e51")

@testset "List all Actions for a Volume" begin
    @test length(actions) == 1
    @test actions[1].id == 72531856
    @test actions[1].status == "completed"
    @test actions[1].actiontype == "attach_volume"
    @test actions[1].started_at == DateTime("2015-11-21T21:51:09")
    @test actions[1].completed_at == DateTime("2015-11-21T21:51:09")
    @test actions[1].resourceid == nothing
    @test actions[1].resourcetype == "volume"
end;

action = getvolumeaction!(testclient, "7724db7c-e098-11e5-b522-000f53304e51",
                           72531856)

@testset "Retrieve an existing Volume Action" begin
    @test action.id == 72531856
    @test action.status == "completed"
    @test action.actiontype == "attach_volume"
    @test action.started_at == DateTime("2015-11-12T17:51:03")
    @test action.completed_at == DateTime("2015-11-12T17:51:14")
    @test action.resourceid == nothing
    @test action.resourcetype == "volume"
end;
