--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        instance_deps.lua
--

-- define module
local instance_deps = instance_deps or {}

-- load modules
local option = require("base/option")
local string = require("base/string")

-- load deps for instance: e.g. option, target and rule
--
-- e.g.
--
-- a.deps = b
-- b.deps = c
--
-- orderdeps: c -> b -> a
--
function instance_deps.load_deps(instance, instances, deps, orderdeps, depspath)
    for _, dep in ipairs(table.wrap(instance:get("deps"))) do
        local depinst = instances[dep]
        if depinst then
            local depspath_sub
            if depspath then
                for idx, name in ipairs(depspath) do
                    if name == dep then
                        local circular_deps = table.slice(depspath, idx)
                        table.insert(circular_deps, dep)
                        os.raise("circular dependency(%s) detected!", table.concat(circular_deps, ", "))
                    end
                end
                depspath_sub = table.join(depspath, dep)
            end
            instance_deps.load_deps(depinst, instances, deps, orderdeps, depspath_sub)
            if not deps[dep] then
                deps[dep] = depinst
                table.insert(orderdeps, depinst)
            end
        end
    end
end

-- return module
return instance_deps
