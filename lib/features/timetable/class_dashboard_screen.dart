import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:mu_study_app/features/attendance/attendance_screen.dart';
import 'add_slot_sheet.dart';
import 'add_announcement_sheet.dart';
import 'add_bookmark_sheet.dart'; // 🚀 WAPAS AA GAYA

class ClassDashboardScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String joinCode;
  final String currentUserId;
  final bool isCreator;

  const ClassDashboardScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.joinCode,
    required this.currentUserId,
    required this.isCreator,
  });

  @override
  State<ClassDashboardScreen> createState() => _ClassDashboardScreenState();
}

class _ClassDashboardScreenState extends State<ClassDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedDay = 1; 
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  final Color primaryColor = const Color(0xFF5A67D8); 
  final Color secondaryColor = const Color(0xFF818CF8); 
  final Color bgColor = const Color(0xFFF3F4F6); 

  @override
  void initState() {
    super.initState();
    // 🚀 LENGTH 4 WAPAS SET KAR DIYA
    _tabController = TabController(length: 4, vsync: this); 
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.className, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Center(child: Text("Invite Code", style: TextStyle(fontWeight: FontWeight.bold))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        child: Text(widget.joinCode, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: 4)),
                      ),
                      const SizedBox(height: 16),
                      const Text("Share this code with your classmates to join.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(30)),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]),
              labelColor: primaryColor,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Schedule"))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Members"))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Updates"))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Bookmarks"))), // 🚀 TAB WAPAS AA GAYA
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildScheduleTab(),
          _buildMembersTab(),
          _buildNotificationsTab(),
          _buildBookmarksTab(), // 🚀 VIEW WAPAS AA GAYA
        ],
      ),
      floatingActionButton: widget.isCreator && _tabController.index != 1
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              elevation: 4,
              onPressed: () {
                if (_tabController.index == 0) {
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddSlotSheet(classId: widget.classId, initialDay: selectedDay.toString()));
                } else if (_tabController.index == 2) {
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddAnnouncementSheet(classId: widget.classId));
                } else if (_tabController.index == 3) {
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddBookmarkSheet(classId: widget.classId));
                }
              },
              icon: Icon(
                _tabController.index == 0 ? Icons.add_rounded :
                _tabController.index == 2 ? Icons.campaign_rounded :
                Icons.bookmark_add_rounded, 
                color: Colors.white
              ),
              label: Text(
                _tabController.index == 0 ? "Add Slot" :
                _tabController.index == 2 ? "Post Update" :
                "Add Bookmark", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
              ),
            )
          : null,
    );
  }

  // ==========================================
  // TAB 1: SCHEDULE 
  // ==========================================
  Widget _buildScheduleTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(days.length, (index) {
                int dayNumber = index + 1;
                bool isSelected = selectedDay == dayNumber;
                return GestureDetector(
                  onTap: () => setState(() => selectedDay = dayNumber),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected 
                          ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))]
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                    ),
                    child: Text(
                      days[index],
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? Colors.white : Colors.grey.shade600),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('timetable_slots').where('class_id', isEqualTo: widget.classId).where('day_of_week', isEqualTo: selectedDay.toString()).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]), child: Icon(Icons.event_available_rounded, size: 64, color: Colors.grey.shade300)),
                      const SizedBox(height: 24),
                      Text("Free Day!", style: TextStyle(color: Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text("No classes scheduled for today.", style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }
              final slots = snapshot.data!.docs;
              return ListView.builder(
                physics: const BouncingScrollPhysics(), 
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slotData = slots[index].data() as Map<String, dynamic>;
                  final slotId = slots[index].id;
                  final subject = slotData['subject_name'] ?? 'Unknown';
                  final teacher = slotData['teacher_name'] ?? 'Unknown';
                  final room = slotData['room_id'] ?? 'Unknown';
                  final startTime = slotData['start_time'] ?? '';
                  final endTime = slotData['end_time'] ?? '';
                  final type = slotData['type'] ?? 'Lecture';
                  bool isLab = type == 'Lab';
                  Color accentColor = isLab ? const Color(0xFFF59E0B) : primaryColor;

                  return InkWell(
                   // onTap: () {
                    //  if (widget.isCreator) {
                    //    Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen(classId: widget.classId, subjectName: subject, slotId: slotId)));
                    //  } else {
                  //      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Only teachers can mark attendance!")));
                     // }
                   // },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                      child: Row(
                        children: [
                          Container(width: 6, height: 100, decoration: BoxDecoration(color: accentColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)))),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(startTime, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87)),
                                      const SizedBox(height: 4),
                                      Text("to", style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(endTime, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  Container(margin: const EdgeInsets.symmetric(horizontal: 16), width: 1, height: 50, color: Colors.grey.shade200),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text(subject, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(type, style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)))
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.person_rounded, size: 16, color: Colors.grey.shade400),
                                            const SizedBox(width: 4),
                                            Expanded(child: Text(teacher, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            Icon(Icons.room_rounded, size: 16, color: Colors.grey.shade400),
                                            const SizedBox(width: 2),
                                            Text(room, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.isCreator)
                                    IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), onPressed: () { FirebaseFirestore.instance.collection('timetable_slots').doc(slotId).delete(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Slot Deleted!"), backgroundColor: Colors.redAccent)); })
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),      
      ],
    );
  }

  // ==========================================
  // TAB 2: MEMBERS 
  // ==========================================
  Widget _buildMembersTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('classes').doc(widget.classId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: primaryColor));
        final classData = snapshot.data!.data() as Map<String, dynamic>?;
        if (classData == null) return const Center(child: Text("Data not found"));
        final membersList = classData['members'] as List<dynamic>? ?? [];
        final creatorId = classData['created_by'];

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: membersList.length,
          itemBuilder: (context, index) {
            String memberId = membersList[index];
            bool isAdmin = memberId == creatorId;
            bool isMe = memberId == widget.currentUserId;
            if (isMe) return _buildMemberCard(title: "You", subtitle: isAdmin ? "Admin" : "Member", isAdmin: isAdmin);
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(memberId).get(),
              builder: (context, userSnapshot) {
                String displayName = "Student (${memberId.substring(0, 5)}...)";
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData != null) displayName = userData['name'] ?? userData['email'] ?? displayName;
                }
                return _buildMemberCard(title: displayName, subtitle: isAdmin ? "Admin" : "Student", isAdmin: isAdmin);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMemberCard({required String title, required String subtitle, required bool isAdmin}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: isAdmin ? primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100, child: Icon(isAdmin ? Icons.shield_rounded : Icons.person_rounded, color: isAdmin ? primaryColor : Colors.grey.shade500)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: isAdmin ? primaryColor : Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: UPDATES
  // ==========================================
  Widget _buildNotificationsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('announcements').where('class_id', isEqualTo: widget.classId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]), child: Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade300)),
                const SizedBox(height: 24),
                Text("No Updates Yet!", style: TextStyle(color: Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text("Any announcements will appear here.", style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        var announcements = snapshot.data!.docs.toList();
        announcements.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          Timestamp? timeA = aData['created_at'] as Timestamp?;
          Timestamp? timeB = bData['created_at'] as Timestamp?;
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA); 
        });
        return ListView.builder(
          physics: const BouncingScrollPhysics(), 
          padding: const EdgeInsets.all(16),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final data = announcements[index].data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Notice';
            final message = data['message'] ?? '';
            final docId = announcements[index].id;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))], border: Border.all(color: primaryColor.withValues(alpha: 0.1), width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.notifications_active_rounded, size: 18, color: primaryColor)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: primaryColor))),
                          ],
                        ),
                      ),
                      if (widget.isCreator)
                        InkWell(onTap: () => FirebaseFirestore.instance.collection('announcements').doc(docId).delete(), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400)))
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 4: BOOKMARKS (WAPAS AA GAYA 🚀)
  // ==========================================
  Widget _buildBookmarksTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookmarks')
          .where('class_id', isEqualTo: widget.classId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
                  child: Icon(Icons.bookmarks_rounded, size: 64, color: Colors.grey.shade300),
                ),
                const SizedBox(height: 24),
                Text("No Bookmarks Yet!", style: TextStyle(color: Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text("Important links will be saved here.", style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        var bookmarks = snapshot.data!.docs.toList();
        bookmarks.sort((a, b) {
          final timeA = (a.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
          final timeB = (b.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA); 
        });

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final data = bookmarks[index].data() as Map<String, dynamic>;
            final docId = bookmarks[index].id;
            final title = data['title'] ?? 'Link';
            final url = data['url'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.language_rounded, color: primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            // 🚀 SMART URL FIX
                            String finalUrl = url;
                            if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
                              finalUrl = 'https://$finalUrl';
                            }
                            final Uri uri = Uri.parse(finalUrl);
                            try {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot open link!")));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid link format!")));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.open_in_new_rounded, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Expanded(child: Text(url, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // 🚀 SAVE TO PROFILE BUTTON
                  IconButton(
                    icon: Icon(Icons.bookmark_add_outlined, color: primaryColor),
                    tooltip: "Save to My Profile",
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).collection('my_bookmarks').add({
                          'title': title,
                          'url': url,
                          'saved_at': FieldValue.serverTimestamp(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Profile Settings! ⭐"), backgroundColor: Colors.green));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving bookmark!"), backgroundColor: Colors.red));
                      }
                    },
                  ),
                  if (widget.isCreator)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => FirebaseFirestore.instance.collection('bookmarks').doc(docId).delete(),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }
}