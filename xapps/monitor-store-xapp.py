import time
import os
import pdb
import csv
import sys


cur_dir = os.path.dirname(os.path.abspath(__file__))
# print("Current Directory:", cur_dir)
sdk_path = cur_dir + "/../xapp_sdk/"
sys.path.append(sdk_path)

import xapp_sdk as ric
import threading


# Define CSV file names and headers
mac_csv_file = 'mac_stats.csv'
rlc_csv_file = 'rlc_stats.csv'
pdcp_csv_file = 'pdcp_stats.csv'

mac_headers = ['Timestamp', 'RNTI', 'CQI', 'PUSCH SNR', 'UL BLER', 'DL BLER', 'UL MCS1', 'UL MCS2', 'DL MCS1', 'DL MCS2', 'UL Throughput', 'DL Throughput']
rlc_headers = ['Timestamp', 'TXPDU WT MS', 'TXBUF OCC Bytes', 'RXBUF OCC Bytes', 'TXPDU RETX PKTS', 'RXPDU DUP PKTS', 'TXPDU DD PKTS', 'RXPDU DD PKTS', 'TXPDU Segmented', 'RXPDU Status PKTS', 'TXSDU PKTS', 'RXSDU PKTS']
pdcp_headers = ['Timestamp', 'RXPDU OO PKTS', 'RXPDU OO Bytes', 'RXPDU DD PKTS', 'RXPDU DD Bytes', 'RXPDU RO Count', 'TXPDU PKTS', 'TXPDU Bytes', 'RXPDU PKTS', 'RXPDU Bytes', 'TXSDU PKTS', 'TXSDU Bytes', 'RXSDU PKTS', 'RXSDU Bytes']


# Initialize CSV files
def init_csv_files():
    with open(mac_csv_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(mac_headers)
    with open(rlc_csv_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(rlc_headers)
    with open(pdcp_csv_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(pdcp_headers)

init_csv_files()

####################
#### MAC INDICATION CALLBACK
####################

# MACCallback class is defined and derived from C++ class mac_cb
#  MACCallback class is defined and derived from C++ class mac_cb
class MACCallback(ric.mac_cb):
    # Define Python class 'constructor'
    def __init__(self):
        # Call C++ base class constructor
        ric.mac_cb.__init__(self)
        super().__init__()
        # Initialize previous dl_aggr_tbs values for the UEs
        self.prev_dl_aggr_tbs_ue1 = 0
        self.prev_dl_aggr_tbs_ue2 = 0

        # Initialize the last reported time
        self.last_report_time = time.time()
        self.stats = []
        
    # Override C++ method: virtual void handle(swig_mac_ind_msg_t a) = 0;
    def handle(self, ind):

        # Get the current time
        current_time = time.time()
        if current_time - self.last_report_time >= 1:
            # Update the last reported time
            self.last_report_time = current_time

            # Print swig_mac_ind_msg_t
            if len(ind.ue_stats) > 0:

                # Collect stats for UE1
                self.stats.append([
                    time.time(),
                    ind.ue_stats[0].rnti,
                    ind.ue_stats[0].wb_cqi,
                    ind.ue_stats[0].pusch_snr,
                    ind.ue_stats[0].ul_bler,
                    ind.ue_stats[0].dl_bler,
                    ind.ue_stats[0].ul_mcs1,
                    ind.ue_stats[0].ul_mcs2,
                    ind.ue_stats[0].dl_mcs1,
                    ind.ue_stats[0].dl_mcs2,
                    ind.ue_stats[0].ul_curr_tbs,
                    ind.ue_stats[0].dl_curr_tbs
                ])
                

####################
#### RLC INDICATION CALLBACK
####################

class RLCCallback(ric.rlc_cb):
    # Define Python class 'constructor'
    def __init__(self):
        # Call C++ base class constructor
        ric.rlc_cb.__init__(self)
        super().__init__()
        self.stats = []
        # Initialize the last reported time
        self.last_report_time = time.time()
    # Override C++ method: virtual void handle(swig_rlc_ind_msg_t a) = 0;
    def handle(self, ind):
        current_time = time.time()
        if current_time - self.last_report_time >= 1:
            # Update the last reported time
            self.last_report_time = current_time
            # Print swig_mac_ind_msg_t
            if len(ind.rb_stats) > 0:

                # Collect stats for RLC
                self.stats.append([
                    time.time(),  # Timestamp
                    ind.rb_stats[0].txpdu_wt_ms,
                    ind.rb_stats[0].txbuf_occ_bytes,
                    ind.rb_stats[0].rxbuf_occ_bytes,
                    ind.rb_stats[0].txpdu_retx_pkts,
                    ind.rb_stats[0].rxpdu_dup_pkts,
                    ind.rb_stats[0].txpdu_dd_pkts,
                    ind.rb_stats[0].rxpdu_dd_pkts,
                    ind.rb_stats[0].txpdu_segmented,
                    ind.rb_stats[0].rxpdu_status_pkts,
                    ind.rb_stats[0].txsdu_pkts,
                    ind.rb_stats[0].rxsdu_pkts
                ])

####################
#### PDCP INDICATION CALLBACK
####################

class PDCPCallback(ric.pdcp_cb):
    # Define Python class 'constructor'
    def __init__(self):
        # Call C++ base class constructor
        ric.pdcp_cb.__init__(self)
        super().__init__()
        self.stats = []
        # Initialize the last reported time
        self.last_report_time = time.time()
   # Override C++ method: virtual void handle(swig_pdcp_ind_msg_t a) = 0;
    def handle(self, ind):
        current_time = time.time()
        if current_time - self.last_report_time >= 1:
            # Update the last reported time
            self.last_report_time = current_time
            # Print swig_mac_ind_msg_t
            if len(ind.rb_stats) > 0:

                # Collect stats for RLC
                self.stats.append([
                    time.time(),  # Timestamp
                    ind.rb_stats[0].rxpdu_oo_pkts,
                    ind.rb_stats[0].rxpdu_oo_bytes,
                    ind.rb_stats[0].rxpdu_dd_pkts,
                    ind.rb_stats[0].rxpdu_dd_bytes,
                    ind.rb_stats[0].rxpdu_ro_count,
                    ind.rb_stats[0].txpdu_pkts,
                    ind.rb_stats[0].txpdu_bytes,
                    ind.rb_stats[0].rxpdu_pkts,
                    ind.rb_stats[0].rxpdu_bytes,
                    ind.rb_stats[0].txsdu_pkts,
                    ind.rb_stats[0].txsdu_bytes,
                    ind.rb_stats[0].rxsdu_pkts,
                    ind.rb_stats[0].rxsdu_bytes
                ])


# Function to write stats to CSV
def write_stats_to_csv(callback, csv_file, headers):
    with open(csv_file, 'a', newline='') as file:
        writer = csv.writer(file)
        for row in callback.stats:
            writer.writerow(row)
    callback.stats.clear()


def periodic_write():
    write_stats_to_csv(mac_cb, mac_csv_file, mac_headers)
    write_stats_to_csv(rlc_cb, rlc_csv_file, rlc_headers)
    write_stats_to_csv(pdcp_cb, pdcp_csv_file, pdcp_headers)
    threading.Timer(10, periodic_write).start()

####################
#### GTP INDICATION CALLBACK
####################

# Create a callback for GTP which derived it from C++ class gtp_cb
class GTPCallback(ric.gtp_cb):
    def __init__(self):
        # Inherit C++ gtp_cb class
        ric.gtp_cb.__init__(self)
    # Create an override C++ method
    def handle(self, ind):
        if len(ind.gtp_stats) > 0:
            t_now = time.time_ns() / 1000.0
            t_gtp = ind.tstamp / 1.0
            t_diff = t_now - t_gtp
            print(f"GTP Indication tstamp {t_now} diff {t_diff} e2 node type {ind.id.type} nb_id {ind.id.nb_id.nb_id}")

def get_cust_tti(tti):
    if tti == "1_ms":
        return ric.Interval_ms_1
    elif tti == "2_ms":
        return ric.Interval_ms_2
    elif tti == "5_ms":
        return ric.Interval_ms_5
    elif tti == "10_ms":
        return ric.Interval_ms_10
    elif tti == "100_ms":
        return ric.Interval_ms_100
    elif tti == "1000_ms":
        return ric.Interval_ms_1000
    else:
        print(f"Unknown tti {tti}")
        exit()

mac_hndlr = []
rlc_hndlr = []
pdcp_hndlr = []
gtp_hndlr = []
####################
####  GENERAL 
####################
if __name__ == '__main__':

    # Start
    ric.init(sys.argv)
    cust_sm = ric.get_cust_sm_conf()

    conn = ric.conn_e2_nodes()
    assert(len(conn) > 0)
    for i in range(0, len(conn)):
        print("Global E2 Node [" + str(i) + "]: PLMN MCC = " + str(conn[i].id.plmn.mcc))
        print("Global E2 Node [" + str(i) + "]: PLMN MNC = " + str(conn[i].id.plmn.mnc))


#        if sm_name == "MAC":
    for i in range(0, len(conn)):
        # MAC
        mac_cb = MACCallback()
        hndlr = ric.report_mac_sm(conn[i].id, ric.Interval_ms_10, mac_cb)
        mac_hndlr.append(hndlr)
        #time.sleep(1)

    for i in range(0, len(conn)):
        # RLC
        rlc_cb = RLCCallback()
        hndlr = ric.report_rlc_sm(conn[i].id, ric.Interval_ms_10, rlc_cb)
        rlc_hndlr.append(hndlr)
        #time.sleep(1)

    for i in range(0, len(conn)):
        # PDCP
        pdcp_cb = PDCPCallback()
        hndlr = ric.report_pdcp_sm(conn[i].id, ric.Interval_ms_10, pdcp_cb)
        pdcp_hndlr.append(hndlr)
        periodic_write()

    time.sleep(10000)

    ### End
    for i in range(0, len(mac_hndlr)):
        ric.rm_report_mac_sm(mac_hndlr[i])

    for i in range(0, len(rlc_hndlr)):
        ric.rm_report_rlc_sm(rlc_hndlr[i])

    for i in range(0, len(pdcp_hndlr)):
        ric.rm_report_pdcp_sm(pdcp_hndlr[i])

    for i in range(0, len(gtp_hndlr)):
        ric.rm_report_gtp_sm(gtp_hndlr[i])

    # Avoid deadlock. ToDo revise architecture
    while ric.try_stop == 0:
        time.sleep(1)

    print("Test finished")
