module One
  Group = Struct.new(:id, :name) do
    def self.from_xml(xml)
      new(xml.id, xml.name)
    end
  end
end
