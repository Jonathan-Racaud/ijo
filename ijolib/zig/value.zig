const ValueType = enum { Result, Bool, Number, Obj, InternalEmptyEntry, InternalTombstone, String };
const Value = union(ValueType) { boolean: Bool, number: Number, obj: Obj };
