--[[
    Nebula Framework - Database System (Shared)
    SQLite-based data persistence
]]

Nebula.database = Nebula.database or {}
Nebula.database.tables = {}

-- Table schema registration
function Nebula.database:RegisterTable(name, schema)
    self.tables[name] = schema
end

-- Get table name with prefix
function Nebula.database:GetTableName(name)
    return "nebula_" .. name
end
