from time import sleep
from Queue import Queue
cimport corotypes

cdef void deliver_fn(cpg_handle_t handle,
        cpg_name *group_name, 
        uint32_t nodeid, 
        uint32_t pid, 
        void *msg, 
        size_t msg_len ):
    queue_in.put({'group_name' : { 
                        'value' : group_name.value,
                        'length' : group_name.length},
                    'nodeid' : nodeid,
                    'pid' : pid,
                    'msg' : <char *>msg,
                    'msg_len' : msg_len})

cdef void confchg_fn(cpg_handle_t handle,
        cpg_name *group_name,
        cpg_address *member_list,
        size_t member_list_entries,
        cpg_address *left_list,
        size_t left_list_entries,
        cpg_address *joined_list,
        size_t joined_list_entries):
    member_list_dict = dict()
    idx = 0
    while idx < member_list_entries:
        member_list_dict[idx]=dict()
        member_list_dict[idx]["nodeid"] = member_list[idx].nodeid
        member_list_dict[idx]["pid"] = member_list[idx].pid
        member_list_dict[idx]["reason"]= member_list[idx].reason
        idx = idx + 1

    idx = 0
    left_list_dict = dict()
    while idx < left_list_entries:
        left_list_dict[idx]=dict()
        left_list_dict[idx]["nodeid"] = left_list[idx].nodeid
        left_list_dict[idx]["pid"] = left_list[idx].pid
        left_list_dict[idx]["reason"]= left_list[idx].reason
        idx = idx + 1

    idx = 0
    joined_list_dict = dict()
    while idx < joined_list_entries:
        joined_list_dict[idx]=dict()
        joined_list_dict[idx]["nodeid"] = joined_list[idx].nodeid
        joined_list_dict[idx]["pid"] = joined_list[idx].pid
        joined_list_dict[idx]["reason"]= joined_list[idx].reason
        idx = idx + 1
    
    queue_ch.put({'group_name' : { 
                    'value' : group_name.value,
                    'length' : group_name.length},
                'member_list' : member_list_dict,
                'member_list_entries' : member_list_entries, 
                'left_list' : left_list_dict, 
                'left_list_entries' : left_list_entries,
                'joined_list' : joined_list_dict,
                'joined_list_entries' : joined_list_entries})

queue_in=None
queue_ch=None

cdef class CPG:
    cdef cpg_handle_t handle
    cdef cpg_guarantee_t guarantee
    cdef cpg_name group_name
    cdef public object queue_in
    cdef public object queue_ch
    def __cinit__(self,name):
        cdef int length
        length = len(name)
        strncpy(self.group_name.value, name, len (name))
        self.group_name.length = length

    def __dealloc__(self):
        """ TODO """
        self.leave()
        sleep(1)
        self.finalize()
        

    def initialize (self):
        cdef cpg_callbacks_t callbacks
        cdef int retval
        # hack to make it possible to use queues from callback
        global queue_in, queue_ch
        queue_in = Queue()
        queue_ch = Queue()
        self.queue_in = queue_in
        self.queue_ch = queue_ch
        callbacks.cpg_deliver_fn = deliver_fn
        callbacks.cpg_confchg_fn = confchg_fn
        retval = cpg_initialize(&self.handle, &callbacks)
        if retval == corotypes.CS_OK:
            #print "initialized with handle=%i" % self.handle
            return True
        else:
            print "initialization failed errcode=%i" % retval
            return False
        
    def finalize (self):
        cdef int retval
        retval = cpg_finalize(self.handle)
        if retval == corotypes.CS_OK:
            #print "Finalized...."
            return True
        else:
            print "did not finalized... errcode=%i" % retval
            return False

        pass

    def fd_get (self):
        """ TODO """
        cdef int fd_val 
        cdef int retval
        retval = cpg_fd_get(self.handle, &fd_val)
        if retval == corotypes.CS_OK:
            #print "File Descriptor %i" % fd_val
            return fd_val
        else:
            print "did not received FD... errcode=%i" % retval
            return None
        
    def context_get (self):
        """ TODO """
        raise NotImplementedError,"Context get not implemented"

    def context_set (self):
        """ TODO """
        raise NotImplementedError, "Context set not implemented"

    def dispatch (self, dispatch_type):
        cdef cs_dispatch_flags_t val
        cdef int retval
        val = dispatch_type
        retval = cpg_dispatch(self.handle, val);
        if retval == corotypes.CS_OK:
            return True
        else:
            print "dispatching failed reason code %i" % retval
            return False

    def join (self):
        cdef int retval
        retval = cpg_join(self.handle,&self.group_name)        
        if retval == corotypes.CS_OK:
            return True
        else:
            print "join to group %s failed reason code %i" % (self.group_name.value, retval)
            return False
        

    def leave (self):
        cdef int retval
        retval = cpg_leave(self.handle,&self.group_name)        
        if retval == corotypes.CS_OK:
            #print "parting from group %s" % self.group_name.value
            return True
        else:
            print "did not leave group %s reason code %i" % (self.group_name.value, retval)
            return True

    def mcast_joined (self,char *msg):
        #cdef cpg_guarantee_t guarantee
        cdef iovec *idata
        idata = <iovec*>malloc(sizeof(iovec))
        idata.iov_base = msg
        idata.iov_len = len (msg)
        cdef int retval
        retval = cpg_mcast_joined(<cpg_handle_t>self.handle,
                                    <cpg_guarantee_t>2, idata, 1)
        free(idata)
        if retval != corotypes.CS_OK:
            print "message send faild..."

    def membership_get (self):
        cdef cpg_address member_list[64] # from testcpg.c
        cdef int member_list_entries
        cdef int retval
        # in function bellow it is not needed to use & before member_list
        # as when it is used it wrongly assumes first array value...
        # but hey it works like this so i really do not care
        retval = cpg_membership_get(self.handle,
                                    &self.group_name,
                                    member_list,
                                    &member_list_entries)
        if retval == corotypes.CS_OK:
            member_list_dict = dict()
            idx = 0
            while idx < member_list_entries:
                member_list_dict[idx]=dict()
                member_list_dict[idx]["nodeid"] = member_list[idx].nodeid
                member_list_dict[idx]["pid"] = member_list[idx].pid
                member_list_dict[idx]["reason"]= member_list[idx].reason
                idx = idx + 1
            return ({'member_list' : member_list_dict})
        else:
            print "did no received membership info reason code %i" %  retval
            return None
        

    def local_get (self):
        cdef unsigned int local_nodeid
        cdef int retval
        retval = cpg_local_get(self.handle, &local_nodeid)
        print "local_node_id %i" % local_nodeid
        
        if retval == corotypes.CS_OK:
            return local_nodeid
        else:
            print "Local get failed reason code %i" % (retval)
            return None


    def flow_control_state_get (self):
        """ TODO """
        raise NotImplementedError,"Flow control not implemented yet..."

    def zcb_alloc (self):
        """ TODO """
        raise NotImplementedError,"Zero copy buffer not used currently"

    def zcb_free (self):
        """ TODO """
        raise NotImplementedError,"Zero copy buffer not used currently"

    def zcb_mcast_joined (self):
        """ TODO """
        raise NotImplementedError,"Zero copy buffer not used currently"

    def iteration_initialize(self):
        """ TODO """
        raise NotImplementedError,"iteration_initialize not used currently"

    def iteration_next(self):
        """ TODO """
        raise NotImplementedError,"iteration_next not used currently"

    def iteration_finalize (self):
        """ TODO """
        raise NotImplementedError,"iteration_finalize not used currently"
    