ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :role, :first_name, :last_name, :phone, :country_code,:organization_id

  actions :edit,:new,:update,:index,:show

  index do
    selectable_column
    id_column
    column :organization
    column :email
    column :phone_number
    column :first_name
    column :last_name
    column :role
    column :created_at
    actions
  end

  filter :email
  filter :role
  filter :created_at

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: User.roles
      f.input :first_name
      f.input :last_name
      f.input :phone
      f.input :country_code
      f.input :organization_id, as: :select, collection: Organization.all.map { |x| [x.name, x.id] }
    end
    f.actions
  end
  
end
