export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      appreciation_entries: {
        Row: {
          appreciation_text: string
          couple_id: string | null
          created_at: string | null
          from_user_id: string | null
          from_user_name: string
          gratitudes: string[] | null
          id: string
          selected_badge: string | null
          sent_at: string | null
          to_user_id: string | null
          to_user_name: string | null
          updated_at: string | null
          viewed_at: string | null
          week_of: string
          win_text: string
        }
        Insert: {
          appreciation_text: string
          couple_id?: string | null
          created_at?: string | null
          from_user_id?: string | null
          from_user_name: string
          gratitudes?: string[] | null
          id?: string
          selected_badge?: string | null
          sent_at?: string | null
          to_user_id?: string | null
          to_user_name?: string | null
          updated_at?: string | null
          viewed_at?: string | null
          week_of: string
          win_text: string
        }
        Update: {
          appreciation_text?: string
          couple_id?: string | null
          created_at?: string | null
          from_user_id?: string | null
          from_user_name?: string
          gratitudes?: string[] | null
          id?: string
          selected_badge?: string | null
          sent_at?: string | null
          to_user_id?: string | null
          to_user_name?: string | null
          updated_at?: string | null
          viewed_at?: string | null
          week_of?: string
          win_text?: string
        }
        Relationships: [
          {
            foreignKeyName: "appreciation_entries_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appreciation_entries_from_user_id_fkey"
            columns: ["from_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appreciation_entries_to_user_id_fkey"
            columns: ["to_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      challenge_check_ins: {
        Row: {
          challenge_id: string | null
          created_at: string | null
          id: string
          note: string
          photo_url: string | null
          progress_percent: number | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          challenge_id?: string | null
          created_at?: string | null
          id?: string
          note: string
          photo_url?: string | null
          progress_percent?: number | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          challenge_id?: string | null
          created_at?: string | null
          id?: string
          note?: string
          photo_url?: string | null
          progress_percent?: number | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "challenge_check_ins_challenge_id_fkey"
            columns: ["challenge_id"]
            isOneToOne: false
            referencedRelation: "growth_challenges"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "challenge_check_ins_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      check_ins: {
        Row: {
          connection_score: number
          couple_id: string | null
          created_at: string | null
          date: string
          id: string
          is_partner: boolean | null
          mood: string
          note: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          connection_score: number
          couple_id?: string | null
          created_at?: string | null
          date: string
          id?: string
          is_partner?: boolean | null
          mood: string
          note?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          connection_score?: number
          couple_id?: string | null
          created_at?: string | null
          date?: string
          id?: string
          is_partner?: boolean | null
          mood?: string
          note?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "check_ins_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "check_ins_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      conflict_sessions: {
        Row: {
          ai_summary_enabled: boolean | null
          ai_summary_text: string | null
          breathing_skipped: boolean | null
          connected_to_past_pattern: boolean | null
          conversation_notes: string | null
          couple_id: string | null
          created_at: string | null
          emotion_free_text: string | null
          emotions: string[] | null
          ended_at: string | null
          follow_up_in_days: number | null
          id: string
          initiator_id: string | null
          needs: string[] | null
          partner_response: string | null
          past_pattern_text: string | null
          readiness: string | null
          resolution_notes: string | null
          resolution_rating: number | null
          started_at: string | null
          trigger_text: string | null
          updated_at: string | null
        }
        Insert: {
          ai_summary_enabled?: boolean | null
          ai_summary_text?: string | null
          breathing_skipped?: boolean | null
          connected_to_past_pattern?: boolean | null
          conversation_notes?: string | null
          couple_id?: string | null
          created_at?: string | null
          emotion_free_text?: string | null
          emotions?: string[] | null
          ended_at?: string | null
          follow_up_in_days?: number | null
          id?: string
          initiator_id?: string | null
          needs?: string[] | null
          partner_response?: string | null
          past_pattern_text?: string | null
          readiness?: string | null
          resolution_notes?: string | null
          resolution_rating?: number | null
          started_at?: string | null
          trigger_text?: string | null
          updated_at?: string | null
        }
        Update: {
          ai_summary_enabled?: boolean | null
          ai_summary_text?: string | null
          breathing_skipped?: boolean | null
          connected_to_past_pattern?: boolean | null
          conversation_notes?: string | null
          couple_id?: string | null
          created_at?: string | null
          emotion_free_text?: string | null
          emotions?: string[] | null
          ended_at?: string | null
          follow_up_in_days?: number | null
          id?: string
          initiator_id?: string | null
          needs?: string[] | null
          partner_response?: string | null
          past_pattern_text?: string | null
          readiness?: string | null
          resolution_notes?: string | null
          resolution_rating?: number | null
          started_at?: string | null
          trigger_text?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "conflict_sessions_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "conflict_sessions_initiator_id_fkey"
            columns: ["initiator_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      couples: {
        Row: {
          anniversary_date: string | null
          appreciation_frequency: string | null
          created_at: string | null
          growth_date_day: number | null
          id: string
          partner_ids: string[]
          updated_at: string | null
        }
        Insert: {
          anniversary_date?: string | null
          appreciation_frequency?: string | null
          created_at?: string | null
          growth_date_day?: number | null
          id?: string
          partner_ids: string[]
          updated_at?: string | null
        }
        Update: {
          anniversary_date?: string | null
          appreciation_frequency?: string | null
          created_at?: string | null
          growth_date_day?: number | null
          id?: string
          partner_ids?: string[]
          updated_at?: string | null
        }
        Relationships: []
      }
      date_ideas: {
        Row: {
          category: string
          completed_date: string | null
          couple_id: string | null
          created_at: string | null
          description: string
          estimated_cost: number | null
          estimated_time: number | null
          id: string
          image_asset: string | null
          is_completed: boolean | null
          title: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          category: string
          completed_date?: string | null
          couple_id?: string | null
          created_at?: string | null
          description: string
          estimated_cost?: number | null
          estimated_time?: number | null
          id?: string
          image_asset?: string | null
          is_completed?: boolean | null
          title: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          category?: string
          completed_date?: string | null
          couple_id?: string | null
          created_at?: string | null
          description?: string
          estimated_cost?: number | null
          estimated_time?: number | null
          id?: string
          image_asset?: string | null
          is_completed?: boolean | null
          title?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "date_ideas_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "date_ideas_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      gratitude_entries: {
        Row: {
          category: string
          content: string
          couple_id: string | null
          created_at: string | null
          date: string
          id: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          category: string
          content: string
          couple_id?: string | null
          created_at?: string | null
          date: string
          id?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          category?: string
          content?: string
          couple_id?: string | null
          created_at?: string | null
          date?: string
          id?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "gratitude_entries_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "gratitude_entries_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      growth_challenges: {
        Row: {
          assigned_to_user_id: string | null
          assigned_to_user_name: string
          check_in_notes: string[] | null
          complexity: string | null
          couple_id: string | null
          created_at: string | null
          how_to_help: string
          id: string
          photo_urls: string[] | null
          progress_percent: number | null
          set_by_user_id: string | null
          set_by_user_name: string
          start_date: string | null
          status: string | null
          target_date: string | null
          title: string
          updated_at: string | null
          why: string
        }
        Insert: {
          assigned_to_user_id?: string | null
          assigned_to_user_name: string
          check_in_notes?: string[] | null
          complexity?: string | null
          couple_id?: string | null
          created_at?: string | null
          how_to_help: string
          id?: string
          photo_urls?: string[] | null
          progress_percent?: number | null
          set_by_user_id?: string | null
          set_by_user_name: string
          start_date?: string | null
          status?: string | null
          target_date?: string | null
          title: string
          updated_at?: string | null
          why: string
        }
        Update: {
          assigned_to_user_id?: string | null
          assigned_to_user_name?: string
          check_in_notes?: string[] | null
          complexity?: string | null
          couple_id?: string | null
          created_at?: string | null
          how_to_help?: string
          id?: string
          photo_urls?: string[] | null
          progress_percent?: number | null
          set_by_user_id?: string | null
          set_by_user_name?: string
          start_date?: string | null
          status?: string | null
          target_date?: string | null
          title?: string
          updated_at?: string | null
          why?: string
        }
        Relationships: [
          {
            foreignKeyName: "growth_challenges_assigned_to_user_id_fkey"
            columns: ["assigned_to_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "growth_challenges_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "growth_challenges_set_by_user_id_fkey"
            columns: ["set_by_user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      in_app_notifications: {
        Row: {
          body: string
          created_at: string | null
          id: string
          is_read: boolean | null
          payload: Json | null
          title: string
          type: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          body: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          payload?: Json | null
          title: string
          type: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          body?: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          payload?: Json | null
          title?: string
          type?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "in_app_notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      milestones: {
        Row: {
          couple_id: string | null
          created_at: string | null
          date: string
          description: string | null
          id: string
          image_asset: string | null
          title: string
          type: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          couple_id?: string | null
          created_at?: string | null
          date: string
          description?: string | null
          id?: string
          image_asset?: string | null
          title: string
          type: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          couple_id?: string | null
          created_at?: string | null
          date?: string
          description?: string | null
          id?: string
          image_asset?: string | null
          title?: string
          type?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "milestones_couple_id_fkey"
            columns: ["couple_id"]
            isOneToOne: false
            referencedRelation: "couples"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "milestones_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          anniversary_date: string | null
          appreciation_frequency: string | null
          appreciation_prompt_day: string | null
          appreciation_prompt_time: string | null
          appreciation_prompts_enabled: boolean | null
          biometric_enabled: boolean | null
          created_at: string | null
          date_of_birth: string | null
          email: string
          fight_better_enabled: boolean | null
          gender_orientation: string | null
          grow_together_enabled: boolean | null
          growth_date_day_of_month: number | null
          growth_date_reminders_enabled: boolean | null
          id: string
          incoming_link_requests: string[] | null
          love_out_loud_enabled: boolean | null
          name: string
          outgoing_link_requests: string[] | null
          pairing_notifications_enabled: boolean | null
          partner_ids: string[] | null
          partner_name: string | null
          password_hash: string | null
          password_salt: string | null
          peace_lily_notifications_enabled: boolean | null
          phone_number: string | null
          profile_photo_base64: string | null
          relationship_feeling: string | null
          relationship_length: string | null
          streak_celebration_enabled: boolean | null
          togetherly_goals: string[] | null
          updated_at: string | null
          weekly_digest_enabled: boolean | null
        }
        Insert: {
          anniversary_date?: string | null
          appreciation_frequency?: string | null
          appreciation_prompt_day?: string | null
          appreciation_prompt_time?: string | null
          appreciation_prompts_enabled?: boolean | null
          biometric_enabled?: boolean | null
          created_at?: string | null
          date_of_birth?: string | null
          email: string
          fight_better_enabled?: boolean | null
          gender_orientation?: string | null
          grow_together_enabled?: boolean | null
          growth_date_day_of_month?: number | null
          growth_date_reminders_enabled?: boolean | null
          id: string
          incoming_link_requests?: string[] | null
          love_out_loud_enabled?: boolean | null
          name: string
          outgoing_link_requests?: string[] | null
          pairing_notifications_enabled?: boolean | null
          partner_ids?: string[] | null
          partner_name?: string | null
          password_hash?: string | null
          password_salt?: string | null
          peace_lily_notifications_enabled?: boolean | null
          phone_number?: string | null
          profile_photo_base64?: string | null
          relationship_feeling?: string | null
          relationship_length?: string | null
          streak_celebration_enabled?: boolean | null
          togetherly_goals?: string[] | null
          updated_at?: string | null
          weekly_digest_enabled?: boolean | null
        }
        Update: {
          anniversary_date?: string | null
          appreciation_frequency?: string | null
          appreciation_prompt_day?: string | null
          appreciation_prompt_time?: string | null
          appreciation_prompts_enabled?: boolean | null
          biometric_enabled?: boolean | null
          created_at?: string | null
          date_of_birth?: string | null
          email?: string
          fight_better_enabled?: boolean | null
          gender_orientation?: string | null
          grow_together_enabled?: boolean | null
          growth_date_day_of_month?: number | null
          growth_date_reminders_enabled?: boolean | null
          id?: string
          incoming_link_requests?: string[] | null
          love_out_loud_enabled?: boolean | null
          name?: string
          outgoing_link_requests?: string[] | null
          pairing_notifications_enabled?: boolean | null
          partner_ids?: string[] | null
          partner_name?: string | null
          password_hash?: string | null
          password_salt?: string | null
          peace_lily_notifications_enabled?: boolean | null
          phone_number?: string | null
          profile_photo_base64?: string | null
          relationship_feeling?: string | null
          relationship_length?: string | null
          streak_celebration_enabled?: boolean | null
          togetherly_goals?: string[] | null
          updated_at?: string | null
          weekly_digest_enabled?: boolean | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
