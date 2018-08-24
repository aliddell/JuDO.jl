struct Account
    dropletlimit::Integer
    floatingiplimit::Integer
    email::String
    uuid::String
    emailverified::Bool
    status::String
    statusmessage::String

    function Account(data::Dict{String})
        new(
            data["droplet_limit"],
            data["floating_ip_limit"],
            data["email"],
            data["uuid"],
            data["email_verified"],
            data["status"],
            data["status_message"]
        )
    end
end

function show(io::IO, a::Account)
    print(io, "Account ($(a.email))")
end

function getaccount!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "account")
    Account(getdata!(client, uri))
end
