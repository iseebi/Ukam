//
//  SkyLight.h
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/17.
//

#ifndef SkyLight_h
#define SkyLight_h

#import <CoreGraphics/CoreGraphics.h>

// from: https://github.com/koekeishiya/yabai/blob/master/src/misc/extern.h

extern int SLSMainConnectionID(void);
extern CFArrayRef SLSCopySpacesForWindows(int cid, int selector, CFArrayRef window_list);
extern CFArrayRef SLSCopyWindowsWithOptionsAndTags(int cid, uint32_t owner, CFArrayRef spaces, uint32_t options, uint64_t *set_tags, uint64_t *clear_tags);
extern CFArrayRef SLSCopyManagedDisplaySpaces(int cid);
extern void SLSMoveWindowsToManagedSpace(int cid, CFArrayRef window_list, uint64_t sid);
extern CFTypeRef SLSWindowQueryWindows(int cid, CFArrayRef windows, int count);
extern CFTypeRef SLSWindowQueryResultCopyWindows(CFTypeRef window_query);
extern bool SLSWindowIteratorAdvance(CFTypeRef iterator);
extern uint32_t SLSWindowIteratorGetParentID(CFTypeRef iterator);
extern uint32_t SLSWindowIteratorGetWindowID(CFTypeRef iterator);
extern uint64_t SLSWindowIteratorGetTags(CFTypeRef iterator);
extern uint64_t SLSWindowIteratorGetAttributes(CFTypeRef iterator);
extern CFArrayRef SLSHWCaptureWindowList(int cid, uint32_t *window_list, int window_count, uint32_t options);
extern CGError SLSSpaceSetCompatID(int cid, uint64_t sid, int workspace);
extern CGError SLSSetWindowListWorkspace(int cid, uint32_t *window_list, int window_count, int workspace);

#endif /* SkyLight_h */
