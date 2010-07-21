cdef extern from "corosync/corotypes.h":
    ctypedef enum cs_error_t:
        CS_OK =                       1
        CS_ERR_LIBRARY =              2
        CS_ERR_VERSION =              3
        CS_ERR_INIT =                 4
        CS_ERR_TIMEOUT =              5
        CS_ERR_TRY_AGAIN =            6
        CS_ERR_INVALID_PARAM =        7
        CS_ERR_NO_MEMORY =            8
        CS_ERR_BAD_HANDLE =           9
        CS_ERR_BUSY =                 10
        CS_ERR_ACCESS =               11
        CS_ERR_NOT_EXIST =            12
        CS_ERR_NAME_TOO_LONG =        13
        CS_ERR_EXIST =                14
        CS_ERR_NO_SPACE =             15
        CS_ERR_INTERRUPT =            16
        CS_ERR_NAME_NOT_FOUND =       17
        CS_ERR_NO_RESOURCES =         18
        CS_ERR_NOT_SUPPORTED =        19
        CS_ERR_BAD_OPERATION =        20
        CS_ERR_FAILED_OPERATION =     21
        CS_ERR_MESSAGE_ERROR =        22
        CS_ERR_QUEUE_FULL =           23
        CS_ERR_QUEUE_NOT_AVAILABLE =  24
        CS_ERR_BAD_FLAGS =            25
        CS_ERR_TOO_BIG =              26
        CS_ERR_NO_SECTIONS =          27
        CS_ERR_CONTEXT_NOT_FOUND =    28
        CS_ERR_TOO_MANY_GROUPS =      30
        CS_ERR_SECURITY =             100

    ctypedef enum cs_dispatch_flags_t:
        CS_DISPATCH_ONE =             1,
        CS_DISPATCH_ALL =             2,
        CS_DISPATCH_BLOCKING =        3
 