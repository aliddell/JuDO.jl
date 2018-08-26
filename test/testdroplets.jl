droplets = getalldroplets!(testclient)
@testset "List all Droplets" begin
    @test length(droplets) == 1
    @test droplets[1].locked == false
    @test isempty(droplets[1].snapshotids)
    @test droplets[1].created_at == DateTime("2014-11-14T16:29:21")
    @test droplets[1].memory == 1024
    @test droplets[1].vcpus == 1
    @test droplets[1].name == "example.com"
    @test droplets[1].status == "active"
    @test droplets[1].networks["v4"][1].gateway == "104.236.0.1"
    @test droplets[1].networks["v4"][1].ipaddress == "104.236.32.182"
    @test droplets[1].networks["v4"][1].netmask == "255.255.192.0"
    @test droplets[1].networks["v4"][1].networktype == "public"
    @test droplets[1].networks["v6"][1].gateway == "2604:A880:0800:0010:0000:0000:0000:0001"
    @test droplets[1].networks["v6"][1].ipaddress == "2604:A880:0800:0010:0000:0000:02DD:4001"
    @test droplets[1].networks["v6"][1].netmask == 64
    @test droplets[1].networks["v6"][1].networktype == "public"
    @test droplets[1].id == 3164444
    @test droplets[1].disk == 25
    @test droplets[1].backupids == [7938002]
    @test droplets[1].sizeslug == "s-1vcpu-1gb"
    @test droplets[1].image.public == true
    @test droplets[1].image.name == "14.04 x64"
    @test droplets[1].image.created_at == DateTime("2014-10-17T20:24:33")
    @test droplets[1].image.sizegigabytes == 2.34
    @test droplets[1].image.id == 6918990
    @test droplets[1].image.distribution == "Ubuntu"
    @test droplets[1].image.slug == "ubuntu-16-04-x64"
    @test droplets[1].image.mindisksize == 20
    @test droplets[1].image.imagetype == "snapshot"
    @test droplets[1].image.regions == ["nyc1", "ams1", "sfo1", "nyc2", "ams2", "sgp1", "lon1", "nyc3", "ams3", "nyc3"]
    @test droplets[1].size == nothing
    @test droplets[1].region.name == "New York 3"
    @test droplets[1].region.features == ["virtio", "private_networking", "backups", "ipv6", "metadata"]
    @test droplets[1].region.slug == "nyc3"
    @test isempty(droplets[1].region.sizes)
    @test droplets[1].region.available == nothing
    @test isempty(droplets[1].volumeids)
    @test droplets[1].features == ["backups", "ipv6", "virtio"]
    @test droplets[1].kernel.name == "Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic"
    @test droplets[1].kernel.id == 2233
    @test droplets[1].kernel.version == "3.13.0-37-generic"
    @test isempty(droplets[1].tags)
end;

droplet = createdroplet!(testclient; name="example.com", region="nyc3",
                         size="s-1vcpu-1gb", image="ubuntu-16-04-x64",
                         backups=false, ipv6=true, tags=["web"])
@testset "Create a new Droplet" begin
    @test droplet.locked == true
    @test isempty(droplet.snapshotids)
    @test droplet.created_at == DateTime("2014-11-14T16:36:31")
    @test droplet.memory == 1024
    @test droplet.vcpus == 1
    @test droplet.name == "example.com"
    @test droplet.status == "new"
    @test isempty(droplet.networks)
    @test droplet.id == 3164494
    @test droplet.disk == 25
    @test isempty(droplet.backupids)
    @test droplet.sizeslug == "s-1vcpu-1gb"
    @test droplet.image == nothing
    @test droplet.size == nothing
    @test droplet.region == nothing
    @test isempty(droplet.volumeids)
    @test droplet.features == ["virtio"]
    @test droplet.kernel.name == "Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic"
    @test droplet.kernel.id == 2233
    @test droplet.kernel.version == "3.13.0-37-generic"
    @test droplet.tags == ["web"]
end;

kernels = getalldropletkernels!(testclient, droplet)
@testset "List all available Kernels for a Droplet" begin
    @test length(kernels) == 1
    @test kernels[1].name == "DO-recovery-static-fsck"
    @test kernels[1].id == 231
    @test kernels[1].version == "3.8.0-25-generic"
end;
