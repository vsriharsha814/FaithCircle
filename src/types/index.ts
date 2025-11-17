export interface User {
  id: string;
  email: string;
  name: string;
  church?: string;
  createdAt: string;
}

export interface JournalEntry {
  id: string;
  userId: string;
  date: string; // ISO date string
  passages: string;
  summary: string;
  reflection: string;
  sharedWithGroups?: string[]; // Group IDs
  createdAt: string;
  updatedAt: string;
}

export interface Sermon {
  id: string;
  userId: string;
  title: string;
  speaker: string;
  date: string; // ISO date string
  passages: string;
  notes: string;
  takeaway: string;
  application: string;
  createdAt: string;
  updatedAt: string;
}

export type VerseStatus = 'not_started' | 'memorizing' | 'mastered';

export interface Verse {
  id: string;
  userId: string;
  reference: string;
  text: string;
  tags: string[];
  status: VerseStatus;
  createdAt: string;
  updatedAt: string;
}

export interface Group {
  id: string;
  name: string;
  inviteCode: string;
  createdBy: string;
  memberIds: string[];
  createdAt: string;
}

export interface GroupPost {
  id: string;
  groupId: string;
  userId: string;
  type: 'journal' | 'verse';
  content: {
    journalId?: string;
    verseId?: string;
    text: string;
  };
  reactions: {
    prayer: string[]; // User IDs who reacted with 🙏
    heart: string[]; // User IDs who reacted with ❤️
  };
  comments: Comment[];
  createdAt: string;
}

export interface Comment {
  id: string;
  postId: string;
  userId: string;
  text: string;
  createdAt: string;
}

