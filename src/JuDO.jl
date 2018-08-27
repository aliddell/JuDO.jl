module JuDO

import Base: show
import Dates: DateTime, unix2datetime, now
import HTTP
import JSON: parse, json

export AbstractClient, Client

export Account, getaccount!
export Action, getallactions!, getaction!
export Volume, VolumeSnapshot, getallvolumes!, createvolume!, getvolume!,
       getallvolumesnapshots!, snapshotvolume!, deletevolume!,
       attachvolume!, removevolume!, resizevolume!, getallvolumeactions!,
       getvolumeaction!, deletevolumesnapshot!
export Certificate, getallcertificates!, getcertificate!, createcertificate!,
       deletecertificate!
export Domain, getalldomains!, createdomain!, getdomain!, deletedomain!
export Record, getalldomainrecords!, getdomainrecord!, createdomainrecord!,
       updatedomainrecord!, deletedomainrecord!
export Droplet, getalldroplets!, getdropletsbytag!, getdroplet!, createdroplet!,
       createdroplets!, getalldropletkernels!, getalldropletsnapshots!,
       getalldropletbackups!, deletedroplet!, getdropletneighbors!

include("client.jl")
include("regions.jl")

include("account.jl")
include("actions.jl")
include("certificates.jl")
include("domains.jl")
include("images.jl")
include("records.jl")
include("sizes.jl")
include("ssh_keys.jl")
include("volumes.jl")

include("droplets.jl")

end # module
