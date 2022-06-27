using System;
using System.Collections;
using ijo.Types;

namespace ijo
{
    typealias ijoValAddr = void*;

    class ijoGC
    {
        private Dictionary<ijoValAddr, uint32> liveObjects;

        public void AddRef(ijoValue* obj)
        {
            if (liveObjects.ContainsKey(obj))
            {
                liveObjects[obj] += 1;
                return;
            }

            liveObjects[obj] = 1;
        }

        public void RemoveRef(ijoValue* obj)
        {
            liveObjects[obj] -= 1;

            if (liveObjects[obj] == 0)
                (*obj).Dispose();
        }
    }
}