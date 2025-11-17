# Project Plan – Faith Circle (React Native App)

A mobile app to help Christians stay rooted in Scripture, track their Bible reading, memorize verses, take sermon notes, and stay accountable with a trusted group of brothers.

---

## 1. Feature Breakdown

### 1.1 Bible Reading Journal
- Add daily journal entry:
  - Passages read
  - Summary (“What did I read?”)
  - Reflection (“What did the Lord speak to me?”)
- Edit past entries
- Two viewing modes:
  - **Calendar View** – tap a date to view entry
  - **List View** – scrollable history
- Share journal summaries with accountability groups

---

### 1.2 Sermon Notes
- Add sermon notes:
  - Title
  - Speaker
  - Date
  - Key passages
  - Main notes
  - Takeaway & weekly application
- View sermon notes in chronological list
- Optional search or filter

---

### 1.3 Verse Locker (Memorization System)
- Save verses with reference, text, and tags
- Status options: Not Started / Memorizing / Mastered
- Verse detail page with simple “memorize mode”
- Track memorized verses over time
- Share progress with group feed:
  - “Added a new verse”
  - “Mastered a verse”

---

### 1.4 Accountability Groups
- Create group or join using invite code
- Group feed shows:
  - Journal entries shared by members
  - Verse progress updates
- React to posts (🙏, ❤️)
- Comment on posts
- See list of group members

---

### 1.5 Authentication & Settings
- Email/password login
- Edit profile (name, church/group name)
- Manage group memberships
- Logout

---

## 2. Screens & Components

### 2.1 Navigation Structure
- **Auth Stack**
  - LoginScreen
  - RegisterScreen
- **Main Tabs**
  - JournalTab
  - SermonsTab
  - VerseLockerTab
  - GroupsTab

---

### 2.2 Journal
**Screens**
- JournalTodayScreen  
- JournalHistoryScreen (Calendar + List)  
- JournalDetailScreen  

**Components**
- JournalEntryForm  
- CalendarView  
- JournalEntryCard  
- ViewToggle (Calendar/List switch)

---

### 2.3 Sermons
**Screens**
- SermonListScreen  
- SermonDetailScreen  
- SermonFormScreen  

**Components**
- SermonForm  
- SermonCard  

---

### 2.4 Verse Locker
**Screens**
- VerseLockerScreen  
- VerseDetailScreen  
- AddVerseScreen  

**Components**
- VerseCard  
- StatusBadge  
- VerseForm  
- MemorizePanel  

---

### 2.5 Groups
**Screens**
- GroupListScreen  
- GroupDetailScreen (feed)  
- CreateOrJoinGroupScreen  

**Components**
- GroupCard  
- GroupPostCard  
- ReactionBar  
- CommentList  
- CommentInput  

---

### 2.6 Shared Components
- PrimaryButton  
- SecondaryButton  
- TextInputField  
- ScreenContainer  
- LoadingSpinner  
- ErrorMessage  
- Tag (for topics/tags in verses/sermons)

---

## 3. Development Phases & To-Do Checklist

### Phase 0 – Project Setup
- [ ] Initialize React Native using Expo  
- [ ] Install React Navigation  
- [ ] Set up backend (Firebase or Supabase)  
- [ ] Create global theme + base components  

---

### Phase 1 – Authentication
- [ ] Build LoginScreen UI  
- [ ] Build RegisterScreen UI  
- [ ] Connect to backend auth  
- [ ] Redirect to MainTabs after login  

---

### Phase 2 – Journal (Core Feature)
- [ ] Build JournalTodayScreen  
- [ ] Create JournalEntryForm component  
- [ ] Implement save entry (CRUD)  
- [ ] Build JournalHistoryScreen:  
  - [ ] Calendar View with markers  
  - [ ] List View of entries  
  - [ ] Toggle component  
- [ ] Build JournalDetailScreen  

---

### Phase 3 – Sermon Notes
- [ ] SermonFormScreen (add/edit)  
- [ ] SermonListScreen  
- [ ] SermonDetailScreen  

---

### Phase 4 – Verse Locker
- [ ] VerseLockerScreen  
- [ ] AddVerseScreen  
- [ ] VerseDetailScreen  
- [ ] MemorizePanel logic  
- [ ] Verse status updates  
- [ ] Progress sharing to group  

---

### Phase 5 – Groups & Feed
- [ ] CreateOrJoinGroupScreen  
- [ ] GroupListScreen  
- [ ] GroupDetailScreen (feed)  
- [ ] GroupPostCard  
- [ ] ReactionBar  
- [ ] Commenting system  

---

### Phase 6 – Polish
- [ ] Input validation  
- [ ] Error messages & toasts  
- [ ] Empty states for lists  
- [ ] Light/dark theme  
- [ ] Offline caching (AsyncStorage)  
- [ ] Optional push notifications  

---

## 4. Tech Stack
- React Native (Expo)  
- React Navigation  
- TypeScript  
- Firebase or Supabase  
- AsyncStorage  
- react-native-calendars for calendar view  

---

## 5. Optional Future Features
- Bible API integration 
- Prayer request board 
- Voice notes for sermons 
- Verse of the week (per group) 
- Grace-based streak tracking