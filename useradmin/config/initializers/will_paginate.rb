if Rails.env.production?
  WillPaginate.per_page = 25
else
  WillPaginate.per_page = 5
end
