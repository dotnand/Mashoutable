class CreateAdvertisementEmails < ActiveRecord::Migration
  def change
    create_table :advertisement_emails do |t|
      t.references :advertisement
      t.string :email

      t.timestamps
    end
    add_index :advertisement_emails, :advertisement_id
  end
end
