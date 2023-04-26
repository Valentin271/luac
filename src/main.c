#include <stdlib.h>

#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"

int hello_world(lua_State *L) {
    // parameters could be retrieved from the stack here

    printf("Hello from C!\n");

    // Number of values returned
    return 0;
}

int main() {
    // Creates a new stack
    lua_State *L = luaL_newstate();
    // Open lua standard libs
    luaL_openlibs(L);

    // Register a C function to be called from lua
    lua_register(L, "hello_world", hello_world);

    // Load & execute lua file
    if (luaL_dofile(L, "script.lua") != LUA_OK) {
        fprintf(stderr, "Error parsing lua file !\n");
        exit(EXIT_FAILURE);
    }

    // Call a lua function from C, must be loaded
    lua_getglobal(L, "concat");
    // Push function parameter
    lua_pushstring(L, "String concatenated ");
    lua_pushstring(L, "in Lua");
    // nb parameters, nb returns
    lua_call(L, 2, 1);

    printf("%s\n", lua_tostring(L, 1));


    lua_close(L);
    return EXIT_SUCCESS;
}
