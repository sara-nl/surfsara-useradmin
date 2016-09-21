module One
  User = Struct.new(:id, :name, :password, :group_ids) do
    def self.from_xml(xml)
      new(xml.id, xml.name, xml['PASSWORD'], xml.groups)
    end
  end
end
