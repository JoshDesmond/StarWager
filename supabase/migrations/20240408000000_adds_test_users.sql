begin;
-- Create test users with deterministic UUIDs
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  created_at,
  updated_at
) VALUES 
  -- Test Host User
  (
    '11111111-1111-1111-1111-111111111111',
    'host@example.com',
    crypt('inert-password', gen_salt('bf')),
    now(),
    now(),
    now(),
    now()
  ),
  -- Test Player 1
  (
    '22222222-2222-2222-2222-222222222222',
    'player1@example.com',
    crypt('inert-password', gen_salt('bf')),
    now(),
    now(),
    now(),
    now()
  ),
  -- Test Player 2
  (
    '33333333-3333-3333-3333-333333333333',
    'player2@example.com',
    crypt('inert-password', gen_salt('bf')),
    now(),
    now(),
    now(),
    now()
  );

-- Create profiles for test users
INSERT INTO profiles (
  id,
  phone_number,
  user_id,
  display_name
) VALUES 
  -- Test Host Profile
  (
    '11111111-1111-1111-1111-111111111111',
    '+15555550001',
    'test-host-001',
    'Test Host'
  ),
  -- Test Player 1 Profile
  (
    '22222222-2222-2222-2222-222222222222',
    '+15555550002',
    'test-player-001',
    'Test Player 1'
  ),
  -- Test Player 2 Profile
  (
    '33333333-3333-3333-3333-333333333333',
    '+15555550003',
    'test-player-002',
    'Test Player 2'
  );

-- Create a test tournament
INSERT INTO tournaments (
  id,
  name,
  created_by,
  start_time,
  end_time,
  is_active
) VALUES (
  '44444444-4444-4444-4444-444444444444',
  'Test Tournament',
  '11111111-1111-1111-1111-111111111111',
  now() + interval '1 day',
  now() + interval '7 days',
  true
);

-- Add users to the tournament
INSERT INTO tournament_users (
  tournament_id,
  profile_id,
  is_host,
  is_entrant
) VALUES 
  -- Host
  (
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    true,
    true
  ),
  -- Player 1
  (
    '44444444-4444-4444-4444-444444444444',
    '22222222-2222-2222-2222-222222222222',
    false,
    true
  ),
  -- Player 2
  (
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    false,
    true
  );

-- Give initial credits to all users
INSERT INTO credits (
  tournament_id,
  profile_id,
  amount
) VALUES 
  -- Host credits
  (
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    1000
  ),
  -- Player 1 credits
  (
    '44444444-4444-4444-4444-444444444444',
    '22222222-2222-2222-2222-222222222222',
    1000
  ),
  -- Player 2 credits
  (
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    1000
  );

-- Create initial credit transactions
INSERT INTO transactions (
  tournament_id,
  profile_id,
  amount,
  type
) VALUES 
  -- Host initial credits
  (
    '44444444-4444-4444-4444-444444444444',
    '11111111-1111-1111-1111-111111111111',
    1000,
    'initial_balance'
  ),
  -- Player 1 initial credits
  (
    '44444444-4444-4444-4444-444444444444',
    '22222222-2222-2222-2222-222222222222',
    1000,
    'initial_balance'
  ),
  -- Player 2 initial credits
  (
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    1000,
    'initial_balance'
  );

commit;
