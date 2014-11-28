class CreateDtes < ActiveRecord::Migration
  def change
    create_table :dtes do |t|
      t.integer :tipo_dte, null: false
      t.integer :folio, null: false
      t.date :fch_emis, null: false
      t.integer :fma_pago, default: 1
      t.date :fch_venc, null: false
      t.string :rut_emisor, null: false
      t.string :rzn_soc, null: false
      t.string :giro_emis, null: false
      t.integer :acteco, null: false
      t.string :dir_origen, null: false
      t.string :cmna_origen, null: false
      t.string :rut_recep, null: false
      t.string :rzn_soc_recep, null: false
      t.integer :mnt_neto, null: false
      t.integer :mnt_exe, null: false
      t.decimal :tasa_iva, default: 19.0, precision: 6, scale: 2
      t.integer :iva, default: 0
      t.integer :mnt_total
      t.string :pdf_url
      
      t.integer :account_id, null: false
      t.integer :company_id, null: false
      t.integer :invoice_id, null: false
      
      t.timestamps
    end
    
    add_index :dtes, :account_id
    add_index :dtes, :company_id
    add_index :dtes, :invoice_id
    
  end
end