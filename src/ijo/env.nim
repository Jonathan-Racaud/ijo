import std/options
import std/tables

import types

proc ijoEnvironment*(parent: ijoEnv): ijoEnv =
  let record = new(ijoRecord)
  result = ijoEnv(parent: parent, record: record)

proc ijoEnvironment*(): ijoEnv =
  let record = new(ijoRecord)
  result = ijoEnv(parent: nil, record: record)

proc resolve(self: var ijoEnv, name: string): Option[ijoRecord] =
  if self.record.hasKey(name):
    return some(self.record)

  if self.parent == nil:
    return

  result = self.parent.resolve(name)

proc lookup(self: var ijoEnv, name: string): Option[ijoValue] =
  let recordResult = self.resolve(name)
  
  if recordResult.isNone:
    return

  let record = recordResult.get
  result = some(record[name])

proc getIdentifier*(self: var ijoEnv, name: string): ijoValue =
  let valueResult = self.lookup(name)

  if valueResult.isNone:
    return ijoValue(kind: ijoUndefined)
  
  result = valueResult.get()

proc setIdentifier*(self: var ijoEnv, name: string, newValue: ijoValue): ijoValue =
  var recordResult = self.resolve(name)

  if recordResult.isNone:
    return ijoValue(kind: ijoUndefined)

  var record = recordResult.get() 
  if record[name].isMutable:
    record[name] = newValue
    record[name].isMutable = true
    return newValue

  return ijoValue(kind: ijoUndefined)

proc defineConst*(self: var ijoEnv, name: string, value: var ijoValue): ijoValue =
  if self.record.hasKey(name):
    return ijoValue(kind: ijoUndefined)

  value.isMutable = false
  self.record[name] = value

  result = value
  
proc defineVar*(self: var ijoEnv, name: string, value: var ijoValue): ijoValue =
  if self.record.hasKey(name):
    return ijoValue(kind: ijoUndefined)

  value.isMutable = true
  self.record[name] = value

  result = value