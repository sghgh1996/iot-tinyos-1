// $Id: RadioCountToLedsC.nc,v 1.7 2010-06-29 22:07:17 scipio Exp $

/*									tab:4
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
 
#include "Timer.h"
#include "RadioCountToLeds.h"
 
/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

module RadioCountToLedsC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend as AMSend1;
    interface AMSend as AMSend2;
    interface AMSend as AMSend3;
    interface AMSend as AMSend4;
    interface AMSend as AMSend5;
    interface AMSend as AMSend6;
    interface Timer<TMilli> as Timer1;
    interface Timer<TMilli> as Timer2;
    interface Timer<TMilli> as Timer3;
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation {

  message_t packet;

  bool locked;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer3.startPeriodic( 200 ); // mote3: 5 Hz
      call Timer2.startPeriodic( 333 ); // mote2: 3 Hz
      call Timer1.startPeriodic( 1000 ); // mote1: 1 Hz
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void Timer1.fired()
  {
    dbg("challengeOne", "challengeOne: timer1 fired, counter is %hu.\n", counter);
    if (locked) {
      return;
    }
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
      if (rcm == NULL) {
		return;
      }

      rcm->counter = counter;
      rcm->sender_id = TOS_NODE_ID;
      
      if (call AMSend1.send(AM_BROADCAST_ADDR, TOS_NODE_ID, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("challengeOne", "challengeOne: sender id sent.\n", counter);	
		
		if (call AMSend2.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
			dbg("challengeOne", "challengeOne: packet sent.\n", counter);
			call Leds.led0Toggle();	
			locked = TRUE;
	 	}
      }
    }
  }
  
  event void Timer2.fired()
  {
    dbg("challengeOne", "challengeOne: timer2 fired, counter is %hu.\n", counter);
    if (locked) {
      return;
    }
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
      if (rcm == NULL) {
		return;
      }

      rcm->counter = counter;
      rcm->sender_id = TOS_NODE_ID;
      
      if (call AMSend3.send(AM_BROADCAST_ADDR, TOS_NODE_ID, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("challengeOne", "challengeOne: sender id sent.\n", counter);	
		
		if (call AMSend4.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
			dbg("challengeOne", "challengeOne: packet sent.\n", counter);
			call Leds.led1Toggle();	
			locked = TRUE;
	 	}
      }
    }
  }
  
  event void Timer3.fired()
  {
    dbg("challengeOne", "challengeOne: timer3 fired, counter is %hu.\n", counter);
    if (locked) {
      return;
    }
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
      if (rcm == NULL) {
		return;
      }

      rcm->counter = counter;
      rcm->sender_id = TOS_NODE_ID;
      
      if (call AMSend5.send(AM_BROADCAST_ADDR, TOS_NODE_ID, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("challengeOne", "challengeOne: sender id sent.\n", counter);	
		
		if (call AMSend6.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
			dbg("challengeOne", "challengeOne: packet sent.\n", counter);
			call Leds.led2Toggle();
			locked = TRUE;
	 	}
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    dbg("challengeOne", "Received packet of length %hhu.\n", len);
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}
    else {
      counter++;
      radio_count_msg_t* rcm = (radio_count_msg_t*)payload;
      if (counter mod 10 == 0) {
		call Leds.led0Off();
		call Leds.led1Off();
		call Leds.led2Off();
      }

      return bufPtr;
    }
  }

  event void AMSend1.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMSend2.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMSend3.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMSend4.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMSend5.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMSend6.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}




