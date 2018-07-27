u = User.find_or_initialize_by(name: "Toby Privett")
u.email = "toby@snaplab.co.uk"
u.password = "password"
u.access_level = :system_manager
u.save!

Service.delete_all

Service.create(
  name: "New Registration",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 124, premium: 180 },
  part_3: { standard: 25, premium: 50 },
  part_4: { standard: 124, premium: 180 })

Service.create(
  name: "New Registration - full",
  standard_days: 10,
  premium_days: 1,
  part_2: { standard: 124, premium: 180 },
  part_4: { standard: 131, premium: 180 })

Service.create(
  name: "New Registration - simple",
  standard_days: 10,
  part_2: { standard: 111 },
  part_4: { standard: 131, premium: 180 })

Service.create(
  name: "Provisional Registration",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 117, premium: 140 })

Service.create(
  name: "Provisional Registration - full",
  standard_days: 3,
  premium_days: 1,
  part_2: { standard: 122, premium: 140 })

Service.create(
  name: "Provisional Registration - simple",
  standard_days: 3,
  part_2: { standard: 122 })

Service.create(
  name: "Convert simple to full registration",
  standard_days: 10,
  premium_days: 1,
  part_2: { standard: 61, premium: 100 })

Service.create(
  name: "Convert provisional to full",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 55, premium: 50 },
  part_2: { standard: 55, premium: 50 })

Service.create(
  name: "Renewal",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 49, premium: 100 },
  part_2: { standard: 49, premium: 100 },
  part_3: { standard: 25, premium: 50 },
  part_4: { standard: 49, premium: 100 })

Service.create(
  name: "Re-registration",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 124, premium: 180 },
  part_3: { standard: 25, premium: 50 },
  part_4: { standard: 124, premium: 180 })

Service.create(
  name: "Re-registration - full",
  standard_days: 10,
  premium_days: 1,
  part_2: { standard: 131, premium: 180 },
  part_4: { standard: 131, premium: 180 })

Service.create(
  name: "Re-registration - simple",
  standard_days: 10,
  part_2: { standard: 111 },
  part_4: { standard: 111 })

Service.create(
  name: "Change of ownership (full)",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 80, premium: 100, subsequent: 15 },
  part_2: { standard: 80, premium: 100, subsequent: 15 },
  part_3: { standard: 25, premium: 50 },
  part_4: { standard: 80, premium: 100, subsequent: 15 })

Service.create(
  name: "Change of ownership - simple",
  standard_days: 10,
  premium_days: 1,
  part_2: { standard: 63, premium: 100, subsequent: 15 },
  part_4: { standard: 63, premium: 100, subsequent: 15 })

Service.create(
  name: "Change of name/port/tonnage (1&4) (expects C&M to be issued)",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 37, premium: 100, subsequent: 17 },
  part_2: { standard: 37, premium: 100, subsequent: 17 },
  part_4: { standard: 37, premium: 100, subsequent: 17 })

Service.create(
  name: "Change of vessel details",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 37, premium: 100, subsequent: 17 },
  part_2: { standard: 37, premium: 100, subsequent: 17 },
  part_3: { standard: 25, premium: 50 },
  part_4: { standard: 37, premium: 100, subsequent: 17 })

Service.create(
  name: "Current transcript",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 21, premium: 50 },
  part_2: { standard: 21, premium: 50 },
  part_3: { standard: 21, premium: 50 },
  part_4: { standard: 21, premium: 50 })

Service.create(
  name: "Historic transcript",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 32, premium: 50 },
  part_2: { standard: 32, premium: 50 },
  part_3: { standard: 32, premium: 50 },
  part_4: { standard: 32, premium: 50 })

Service.create(
  name: "Duplicate certificate",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 21, premium: 50 },
  part_2: { standard: 21, premium: 50 },
  part_3: { standard: 25, premium: 50 },
  part_4: { standard: 21, premium: 50 })

Service.create(
  name: "Mortgage intent",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 25, premium: 50 },
  part_2: { standard: 25, premium: 50 })

Service.create(
  name: "Mortgage registration",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 84, premium: 100, subsequent: 15 },
  part_2: { standard: 84, premium: 100, subsequent: 15 })

Service.create(
  name: "Transfer in",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 115, premium: 50 })

Service.create(
  name: "Transfer out",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 35, premium: 100 })

Service.create(
  name: "Courier/postage fee (allocate funds, no processing)",
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_3: { standard: 0 },
  part_4: { standard: 0 })

Service.create(
  name: "Copy of a document relating to a registration",
  standard_days: 10,
  premium_days: 1,
  part_1: { standard: 13, premium: 50 },
  part_2: { standard: 13, premium: 50 },
  part_3: { standard: 13, premium: 50 },
  part_4: { standard: 13, premium: 50 })

Service.create(
  name: "Change of address",
  standard_days: 10,
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_3: { standard: 0 },
  part_4: { standard: 0 })

Service.create(
  name: "General Enquiry/other non-fee task",
  standard_days: 10,
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_3: { standard: 0 },
  part_4: { standard: 0 })

Service.create(
  name: "Mortgage discharge",
  standard_days: 10,
  part_1: { standard: 0 },
  part_2: { standard: 0 })

Service.create(
  name: "Mortgage transfer",
  standard_days: 10,
  part_1: { standard: 0 },
  part_2: { standard: 0 })

Service.create(
  name: "Registration Closure",
  standard_days: 10,
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_3: { standard: 0 },
  part_4: { standard: 0 })

Service.create(
  name: "Carving and marking receipt",
  standard_days: 3,
  premium_days: 1,
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_4: { standard: 0 })

Service.create(
  name: "Issue CSR",
  standard_days: 3,
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_4: { standard: 0 })

Service.create(
  name: "Manual Override",
  part_1: { standard: 0 },
  part_2: { standard: 0 },
  part_4: { standard: 0 })
