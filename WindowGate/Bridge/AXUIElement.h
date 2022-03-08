//
//  AXUIElement.h
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/7/22.
//

#ifndef AXUIElement_h
#define AXUIElement_h

#import <ApplicationServices/ApplicationServices.h>

extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);

#endif /* AXUIElement_h */
