from corotypes cimport cs_error_t, cs_dispatch_flags_t

cdef extern from "stdint.h":
    ctypedef unsigned long int uint64_t
    ctypedef unsigned int uint32_t

    
cdef extern from "stdlib.h":
    ctypedef int size_t
    void *memcpy(void *, void *, int)
    void *malloc(size_t size)
    void free(void *ptr)
    
cdef extern from "sys/uio.h":
    cdef struct iovec:
        void *iov_base
        size_t iov_len


cdef extern from "string.h":
    char *strncpy(char *dest, char *src, size_t n)
    char *strdup(char *s)
    void *memcpy(void *dest, void *src, size_t n)    

    
cdef extern from "corosync/cpg.h":
    ctypedef uint64_t cpg_handle_t

    ctypedef uint64_t cpg_iteration_handle_t

    ctypedef enum cpg_guarantee_t:
        CPG_TYPE_UNORDERED
        CPG_TYPE_FIFO
        CPG_TYPE_AGREED
        CPG_TYPE_SAFE

    enum cpg_flow_control_state_t:
        CPG_FLOW_CONTROL_DISABLED
        CPG_FLOW_CONTROL_ENABLED

    enum cpg_reason_t:
        CPG_REASON_JOIN	=	    1
        CPG_REASON_LEAVE =	    2
        CPG_REASON_NODEDOWN =	    3
        CPG_REASON_NODEUP =	    4
        CPG_REASON_PROCDOWN =	    5

    enum cpg_iteration_type_t:
        CPG_ITERATION_NAME_ONLY	=   1
        CPG_ITERATION_ONE_GROUP	=   2
        CPG_ITERATION_ALL =	    3

    struct cpg_address:
        uint32_t nodeid
        uint32_t pid
        uint32_t reason

    
    DEF MAX_NAME_LENGTH = 128
    struct cpg_name:
        uint32_t length
        char value[MAX_NAME_LENGTH]

    DEF CPG_MEMBERS_MAX = 128
    struct cpg_iteration_description_t:
        cpg_name group
        uint32_t nodeid
        uint32_t pid

    ctypedef void (*cpg_deliver_fn_t) ( cpg_handle_t handle,
        cpg_name *group_name, 
        uint32_t nodeid, 
        uint32_t pid, 
        void *msg, 
        size_t msg_len )

    ctypedef void (*cpg_confchg_fn_t) ( cpg_handle_t handle,
        cpg_name *group_name,
        cpg_address *member_list,
        size_t member_list_entries,
        cpg_address *left_list,
        size_t left_list_entries,
        cpg_address *joined_list,
        size_t joined_list_entries)

    ctypedef struct cpg_callbacks_t:
        cpg_deliver_fn_t cpg_deliver_fn
        cpg_confchg_fn_t cpg_confchg_fn

    cs_error_t cpg_initialize (
        cpg_handle_t *handle,
        cpg_callbacks_t *callbacks)

    cs_error_t cpg_finalize (
        cpg_handle_t handle)

    cs_error_t cpg_fd_get (
        cpg_handle_t handle,
        int *fd)

    cs_error_t cpg_context_get (
        cpg_handle_t handle,
        void **context)

    cs_error_t cpg_context_set (
        cpg_handle_t handle,
        void *context)

    cs_error_t cpg_dispatch (
        cpg_handle_t handle,
        cs_dispatch_flags_t dispatch_types)


    cs_error_t cpg_join (
        cpg_handle_t handle,
        cpg_name *group)

    cs_error_t cpg_leave (
        cpg_handle_t handle,
        cpg_name *group)

    cs_error_t cpg_mcast_joined (
        cpg_handle_t handle,
        cpg_guarantee_t guarantee,
        iovec *iovec,
        unsigned int iov_len)

    cs_error_t cpg_membership_get (
        cpg_handle_t handle,
        cpg_name *groupName,
        cpg_address *member_list,
        int *member_list_entries)

    cs_error_t cpg_local_get (
        cpg_handle_t handle,
        unsigned int *local_nodeid)

    cs_error_t cpg_flow_control_state_get (
        cpg_handle_t handle,
        cpg_flow_control_state_t *flow_control_enabled)

    cs_error_t cpg_zcb_alloc (
        cpg_handle_t handle,
        size_t size,
        void **buffer)

    cs_error_t cpg_zcb_free (
        cpg_handle_t handle,
        void *buffer)

    cs_error_t cpg_zcb_mcast_joined (
        cpg_handle_t handle,
        cpg_guarantee_t guarantee,
        void *msg,
        size_t msg_len)

    cs_error_t cpg_iteration_initialize(
        cpg_handle_t handle,
        cpg_iteration_type_t iteration_type,
        cpg_name *group,
        cpg_iteration_handle_t *cpg_iteration_handle)

    cs_error_t cpg_iteration_next(
        cpg_iteration_handle_t handle,
        cpg_iteration_description_t *description)

    cs_error_t cpg_iteration_finalize (
        cpg_iteration_handle_t handle)
