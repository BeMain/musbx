import 'dart:math';

import 'package:flutter/material.dart';
import 'package:musbx/note/temperament.dart';

/// Representation of a musical note, with a given pitch.
@immutable
class Note {
  /// The frequency of A4, in Hz. Used as a reference for all other notes.
  /// Defaults to 440 Hz.
  static double a4frequency = 440;

  /// Names of all notes, starting with A.
  static const List<String> noteNames = [
    "A",
    "B♭",
    "B",
    "C",
    "D♭",
    "D",
    "E♭",
    "E",
    "F",
    "G♭",
    "G",
    "A♭",
  ];

  /// Create note from a given [frequency] in Hz.
  /// [frequency] must be greater than 0.
  const Note.fromFrequency(this.frequency)
      : assert(frequency > 0, "Frequency must be greater than 0");

  /// The note with [a4frequency], used as a reference for all other notes.
  Note.a4() : frequency = a4frequency;

  Note.inScale(
    Note root,
    int scaleStep, {
    Temperament temperament = const EqualTemperament(),
  }) : frequency = root.frequency * temperament.frequencyRatio(scaleStep);

  factory Note.relativeToA4(
    int semitonesFromA4, {
    Temperament temperament = const EqualTemperament(),
  }) =>
      Note.inScale(Note.a4(), semitonesFromA4);

  /// The frequency of this note, in Hz.
  final double frequency;

  /// The number of whole octaves between this note and C4 (the note 3 semitones below A4).
  int get octave => ((semitonesFromA4 - 3) / 12).floor();

  /// The number of whole semitones between this note and A4.
  int get semitonesFromA4 =>
      (12 * log(frequency / a4frequency) / log(2)).round();

  /// The number of whole cents between this note and A4.
  int get centsFromA4 => (1200 * log(frequency / a4frequency) / log(2)).round();

  /// The name of this note, e.g C3.
  String get name => "${noteNames[(semitonesFromA4) % 12]}${octave + 5}";

  /// The number of cents between this [frequency] and the closest semitone.
  double get pitchOffset => centsFromA4 - semitonesFromA4 * 100;

  Note operator +(Note other) =>
      Note.fromFrequency(frequency + other.frequency);

  Note operator -(Note other) =>
      Note.fromFrequency(frequency - other.frequency);
}