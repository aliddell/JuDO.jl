struct Record
    id::Integer
    rtype::String
    name::String
    data::String
    priority::Nullable{Integer}
    port::Nullable{Integer}
    ttl::Integer
    weight::Nullable{Integer}
    flags::Nullable{Integer}
    tag::Nullable{String}

    function Record(data::Dict{String})
        new(
            data["id"],
            data["type"],
            data["name"],
            data["data"],
            data["priority"],
            data["port"],
            data["ttl"],
            data["weight"],
            data["flags"],
            data["tag"],
        )
    end
end

function show(io::IO, r::Record)
    print(io, "Record ($(r.rtype), $(r.name))")
end

function get_all_domain_records(manager::Manager, domain_name::String)
    response = get_data(manager, joinpath(ENDPOINT, "domains", domain_name,
                        "records?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["domain_records"]

        records = Array{Record, 1}(meta["total"])

        for (i, record) in enumerate(data)
            records[i] = Record(record)
        end
    else
        error("Received error $(response.status)")
    end

    records
end

function get_all_domain_records(manager::Manager, domain::Domain)
    get_all_domain_records(manager, domain.name)
end

function get_domain_record(manager::Manager, domain_name::String, record_id::Integer)
    response = get_data(manager, joinpath(ENDPOINT, "domains", domain_name,
                        "records", "$record_id"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        data = body["domain_record"]

        record = Record(data)
    else
        error("Received error $(response.status)")
    end
end

function get_domain_record(manager::Manager, domain::Domain, record_id::Integer)
    get_domain_record(manager, domain.name, record_id)
end

function get_domain_record(manager::Manager, domain_name::String, record::Record)
    get_domain_record(manager, domain_name, record.id)
end

function get_domain_record(manager::Manager, domain::Domain, record::Record)
    get_domain_record(manager, domain.name, record.id)
end
